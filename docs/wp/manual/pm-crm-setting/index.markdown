---
author: t-matsuo
comments: false
date: 2010-09-05 16:46:43+00:00
layout: page
permalink: /wp/manual/pm-crm-setting
published: false
slug: pm-crm-setting
title: crmコマンドを用いたPacemakaer のリソース設定方法
wordpress_id: 546
---

Pacemaker で制御するリソースを設定するには、crm コマンドを使用します。以下にcrmコマンドの基本的な使い方を記述します。前提として、[CentOS 5上にPacemakerのインストール](/wp/archives/4219)が完了し、Pacemakerが起動しているとします。クラスタ制御部は、Corosync、Heartbeat どちらでも構いません。

まず、crm コマンドを起動します。(以下太字が実際に入力する部分です)
<pre class="wp-caption" style="text-align: left;">[root@pm01 ~]# <strong>crm</strong>
crm(live)#</pre>


リソースの設定モードに入ります。
<pre class="wp-caption" style="text-align: left;">crm(live)# <strong>configure</strong>
crm(live)configure#</pre>


現在の設定をshowコマンドで確認します。何も設定をしていないので、表示されるのはノード名（サーバ名)と、バージョン、使用しているクラスタ制御部名(以下の例ではHeartbeat3を使用)だけです。
<pre class="wp-caption" style="text-align: left;">crm(live)configure# <strong>show</strong>
node $id="0c140f90-7de3-438f-b1b5-3b9722bbde21" pm01
node $id="62b25071-2d16-4e9e-a323-af21616d5269" pm02
property $id="cib-bootstrap-options" \
        dc-version="1.0.9-89bd754939df5150de7cd76835f98fe90851b677" \
        cluster-infrastructure="Heartbeat"</pre>


では、リソースをPacemakerに追加していきます。

PacemakerにはあらかじめApacheやPostgreSQL, Tomcatといったアプリケーションを制御するためのスクリプト(リソースエージェント(RA))をはじめ、ファイルシステム、Ping監視といったRAが用意されています。どのようなRAが存在するかは、/usr/lib/ocf/resource.d/heartbeat/ ディレクトリを覗いてみてください。

ここでは、Dummyという「何もしない」リソースを設定してみます。
以下ではタイムアウト値や監視間隔の設定をしていますが、何もしないリソースなので、あまり意味はありません。あくまで参考です。一つのリソースを定義する場合、1行で記述する必要がありますので、行が長くなる場合は"\" で改行してください。
<pre class="wp-caption" style="text-align: left;">crm(live)configure# <strong>primitive dummy-resource ocf:pacemaker:Dummy \</strong>  <span style="color: #ff0000;">   ← "dummy-resource"は任意の文字列(ID)</span>
&gt; <strong>op start interval="0s" timeout="90s" \</strong>← dummy-resource の起動時のタイムアウト値の設定
&gt; <strong>op monitor interval="3s" timeout="20s" \</strong>          ← dummy-resource の監視間隔と、タイムアウト値の設定
&gt; <strong>op stop interval="0s" timeout="100s"</strong>              ← dummy-resource の停止時のタイムアウト値の設定</pre>


 

PacemakerにはSTONITHという機能があり、制御不能のサーバを強制的に電源OFFできます。
デフォルトでSTONITHが有効になっていますが、今回はDummyリソースのみの設定例のため、STONITHの設定は省略します。
ただし、設定を行わないとエラーになりますので、STONITH機能を明示的にOFFにします。
※実際のサービス環境では、STONITH を使用することを強く薦めます。
また、今回は2台のサーバしか使用しないので、クォーラムをignoreに設定します。
(クォーラムがよくわからない場合、"2台の時はignoreを使用する" は、おまじないと思ってください ^^)
(STONITH, クォーラムを勉強したい場合は、この辺りを参考に。 [/wp/archives/604](/wp/archives/604) )
<pre class="wp-caption" style="text-align: left;">crm(live)configure# <strong>property $id="cib-bootstrap-options" \</strong>
&gt; <strong>stonith-enabled="false"</strong> \
&gt; <strong>no-quorum-policy="ignore"</strong></pre>


上記を打ち込んでもすぐには反映されません。まずは、設定した内容を確認します。
※showで表示される内容を別のテキストファイルに保存しておくことで、同じ設定を再現できます。
<pre class="wp-caption" style="text-align: left;">crm(live)configure# <strong>show</strong>
node $id="0c140f90-7de3-438f-b1b5-3b9722bbde21" pm01
node $id="62b25071-2d16-4e9e-a323-af21616d5269" pm02
<span style="color: #ff0000;">primitive dummy-resource ocf:pacemaker:Dummy \
 op start interval="0s" timeout="90s" \
 op monitor interval="3s" timeout="20s" \
 op stop interval="0s" timeout="100s"</span>
property $id="cib-bootstrap-options" \
 dc-version="1.0.9-89bd754939df5150de7cd76835f98fe90851b677" \
 cluster-infrastructure="Heartbeat" \
 <span style="color: #ff0000;">stonith-enabled="false" \</span>
 <span style="color: #ff0000;">no-quorum-policy="ignore"</span></pre>


設定を反映します。
<pre class="wp-caption" style="text-align: left;">crm(live)configure# <span style="color: #000000;"><strong>commit</strong></span></pre>


別のターミナルを開き、Pacemakerの状態を確認します。設定したdummy-resource がpm01上で起動したことが確認できます。
<pre class="wp-caption" style="text-align: left;">[root@pm01 ~]# <strong>crm_mon</strong>
============
Last updated: Mon Sep  6 10:10:10 2010
Stack: Heartbeat
Current DC: pm02 (62b25071-2d16-4e9e-a323-af21616d5269) - partition with quorum
Version: 1.0.9-89bd754939df5150de7cd76835f98fe90851b677
2 Nodes configured, unknown expected votes
1 Resources configured.
===========

Online: [ pm01 pm02 ]

<span style="color: #ff0000;">dummy-resource  (ocf::pacemaker:Dummy): Started pm01</span></pre>


今回はDummyのリソースなので故障することはありません。
そこで、pm01のサーバの電源を落としてみてください。pm02上でcrm_monを見ると、pm02 上にdummy-resourceがフェイルオーバーしていることを確認できます。
<pre class="wp-caption" style="text-align: left;">[root@pm02 ~]# <strong>crm_mon</strong>
============
Last updated: Mon Sep  6 10:10:11 2010
Stack: Heartbeat
Current DC: pm02 (62b25071-2d16-4e9e-a323-af21616d5269) - partition with quorum
Version: 1.0.9-89bd754939df5150de7cd76835f98fe90851b677
2 Nodes configured, unknown expected votes
1 Resources configured.
===========

Online: [ pm02 ]
<span style="color: #ff0000;">OFFLINE: [ pm01 ]</span>

<span style="color: #ff0000;">dummy-resource  (ocf::pacemaker:Dummy): Started pm02</span></pre>


設定を完全にすべて消したい場合は、全てのサーバ上のPacemakerを停止し、全てのサーバの/var/lib/heartbeat/crm/ ディレクトリ内のファイルを全て削除してください。
<pre class="wp-caption" style="text-align: left;">[root@pm01 ~]# <strong>/etc/init.d/heartbeat stop</strong> または <strong>/etc/init.d/corosync stop</strong>
Stopping High-Availability services:                       [  OK  ]
[root@pm02 ~]# <strong><strong>/etc/init.d/heartbeat stop</strong></strong> または <strong><strong>/etc/init.d/corosync stop</strong></strong>
Stopping High-Availability services:                       [  OK  ]

[root@pm01 ~]# <strong>rm -f /var/lib/heartbeat/crm/*</strong>
[root@pm02 ~]# <strong>rm -f /var/lib/heartbeat/crm/*</strong></pre>


以上簡単な設定例、動作例でした。

実際には、STONITHを設定したり、アプリケーションの場合は設定ファイルの場所や監視方法を設定したりする必要がありますが、詳細についは、PacemakerのマニュアルやRAの説明を参考にしてください。

 

また、外部サイトにも、構築や運用例の記事を寄稿していますので、参考にしてみてください。
[](http://gihyo.jp/admin/serial/01/pacemaker)

[gihyo.jp の記事 ](http://gihyo.jp/admin/serial/01/pacemaker)

[オープンソースカンファレンスでの発表資料](/wp/archives/tag/osc)

[最新動向 : 月間あんどりゅーくん](/wp/?s=%E5%88%A5%E5%86%8A%E3%81%82%E3%82%93%E3%81%A9%E3%82%8A%E3%82%85%E3%83%BC%E3%81%8F%E3%82%93)

 
