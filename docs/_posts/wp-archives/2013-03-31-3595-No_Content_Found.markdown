---
author: admin
comments: false
date: 2013-03-31 07:23:02+00:00
layout: post
permalink: /wp/archives/3595
published: false
slug: No Content Found
title: DRBDクラスタでローカルディスクが壊れたときにフェールオーバさせる方法
wordpress_id: 3595
categories:
- 読み物
tags:
- DRBD
- pacemaker
---

## はじめに


共有ディスクの代わりにDRBDを使ったPacemakerクラスタが増えています。
DRBDを使うと、単一障害点(Single Point of Failure)を持たない「シェアードナッシング・クラスタ」を容易に実現できます。これは、高可用性を追求する上できわめて大きなメリットです。
しかし、DRBDを使ったクラスタの場合、どちらかのサーバのディスクにI/Oエラーが発生したときの対策という、共有ディスク方式には存在しない障害対策が不可欠です。とくに、稼働系のディスク故障は、サービスの継続やパフォーマンスに関わる関心事になります。


## 稼働系のDRBDデータ領域が故障したら


稼働系サーバのDRBDデータ領域でI/Oエラーが発生したら、DRBDはそのディスクを切り離して、待機系サーバ側のディスクを使ったI/Oに切り替えるモードを提供しています。

    
        disk {
            on-io-error detach;
        }


on-io-errorには、pass-on、call-local-io-errorという値も指定できますが、detachが推奨値になっています。
稼働系サーバのローカルディスクが使えなくなっても、待機系サーバのディスクを使ってサービスを継続できます。これは可用性の観点から見て望ましいことですが、すべてのデータの読み書きがネットワーク経由になってしまうため、パフォーマンス低下が懸念されます。
さらに、ディスク故障に気づかないまま運用を続けると、待機系のディスクまで壊れてしまうという最悪の事態も懸念されます。
したがって、可動系のDRBDデータ領域が故障したら、これをトリガとしてフェールオーバしてくれるのが望ましい、ということになります。


## default-resource-stickiness=200がカギ


稼働系サーバのDRBDデータ領域が正常な場合、DRBDリソースエージェントのmonitorアクションは、10000というスコアをPacemakerに返します。ところがDRBDデータ領域に故障が起きてローカルディスクを切り離すと、10というスコアを返すようになります。
Pacemakerは10000や10というスコアも考慮してリソースの配置を考慮します。このとき、default-resource-stickiness=INFINITYになっていれば、このスコアの違いは無視されることになり、結果としてフェールオーバは起こりません。
DRBDはその動作状態に応じて、10000、10以外のスコアも返します(詳しくはリソースエージェントのソースを見てください)。他の値のことも考慮した場合、default-resource-stickinessの値が200前後になっていれば、ローカルディスクのエラーがフェールオーバのトリガになってくれます。


## 例


cluster1とcluster2の2台のサーバで、DRBDをべーすにしたApacheのHAクラスタを構成し、ディスクI/Oエラーの影響を調べてみました。
DRBDの設定は以下のとおりです。

    
    global {
        usage-count no;
    }
    
    resource r0 {
        protocol C;
    
        syncer {
            rate 20M;
        }
    
        disk {
            <span style="color: #ff0000;">on-io-error   detach</span>;
        }
    
        device /dev/drbd0;
        disk   /dev/vg/lv01;
    
        on cluster1 {
            address 10.0.0.3:7788;
            meta-disk internal;
        }
        on cluster2 {
            address 10.0.0.4:7788;
            meta-disk internal;
        }
    }


クラスタの設定は次のとおりです。

    
    property <span style="color: #ff0000;">default-resource-stickiness="200"</span> \
            no-quorum-policy="ignore" \
            stonith-enabled="false"
    primitive alert ocf:heartbeat:MailTo \
            params email="root" subject="alert from webserver cluster" \
            op start interval="0" timeout="20" \
            op stop interval="0" timeout="20"
    primitive drbd_r0 ocf:linbit:drbd \
            params drbd_resource="r0" \
            op monitor interval="20" role="Slave" timeout="40" \
            op monitor interval="10" role="Master" timeout="40" \
            op start interval="0" timeout="240" \
            op stop interval="0" timeout="100"
    primitive httpd ocf:heartbeat:apache \
            params configfile="/etc/httpd/conf/httpd.conf" \
            op start interval="0" timeout="60" \
            op stop interval="0" timeout="90" \
            op monitor interval="20" timeout="30"
    primitive mount ocf:heartbeat:Filesystem \
            params device="/dev/drbd0" fstype="ext4" directory="/h" options="noatime" \
            op monitor interval="10" timeout="60" \
            op start interval="0" timeout="60" \
            op stop interval="0" timeout="60"
    primitive vip ocf:heartbeat:IPaddr2 \
            params ip="10.30.101.6" cidr_netmask="16" \
            op monitor interval="30" timeout="60"
    group webserver alert vip mount httpd
    ms ms_drbd_r0 drbd_r0 \
            meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
    location loc_webserver webserver 100: cluster1
    colocation col_drbd_webserver inf: webserver ms_drbd_r0:Master
    order ord_drbd_webserver inf: ms_drbd_r0:promote webserver:start


このクラスタを起動すると、cluster1が稼働系になります。

    
    Online: [ cluster2 cluster1 ]
    
     Master/Slave Set: ms_drbd_r0
         Masters: [ cluster1 ]
         Slaves: [ cluster2 ]
     Resource Group: webserver
         alert      (ocf::heartbeat:MailTo):        Started cluster1
         vip        (ocf::heartbeat:IPaddr2):       Started cluster1
         mount      (ocf::heartbeat:Filesystem):    Started cluster1
         httpd      (ocf::heartbeat:apache):        Started cluster1


このとき、cluster1側のDRBDの動作状態は次のようになっています。

    
    version: 8.3.15 (api:88/proto:86-97)
    GIT-hash: dc4c32498e9cbf35734c4716b65ddd6fbd6e1eb4 build by buildsystem@linbit, 2013-01-30 08:31:13
     0: cs:Connected ro:Primary/Secondary ds:UpToDate/UpToDate C r-----
        ns:1 nr:77773 dw:77774 dr:686 al:19 bm:48 lo:0 pe:0 ua:0 ap:0 ep:1 wo:f oos:0


ディスクI/Oエラーを起こす代わりに、cluster1側で次のコマンドを実行して、
ローカルディスクを切り離してみます。

    
    drbdadm detach r0


すると、次のようにDRBDの動作状態が変化します。

    
    GIT-hash: dc4c32498e9cbf35734c4716b65ddd6fbd6e1eb4 build by buildsystem@linbit, 2013-01-30 08:31:13
     0: cs:Connected ro:Primary/Secondary ds:<span style="color: #ff0000;">Diskless</span>/UpToDate C r-----
        ns:1 nr:77773 dw:77774 dr:693 al:19 bm:48 lo:0 pe:0 ua:0 ap:0 ep:1 wo:f oos:0


しばらく待っていると、Pacemakerは稼働系DRBDデータ領域の障害を検出してフェールオーバを引き起こします。

    
    Online: [ cluster2 cluster1 ]
    
     Master/Slave Set: ms_drbd_r0
         Masters: [ cluster2 ]
         Slaves: [ cluster1 ]
     Resource Group: webserver
         alert      (ocf::heartbeat:MailTo):        Started cluster2
         vip        (ocf::heartbeat:IPaddr2):       Started cluster2
         mount      (ocf::heartbeat:Filesystem):    Started cluster2
         httpd      (ocf::heartbeat:apache):        Started cluster2


しかし、default-resource-stickiness=INFINITYになっている場合は、ローカルディスクを切り離してもフェールオーバは起こりません。試してみてください。


# おわりに


DRBDを使うと、2台のサーバのDRBDデータ領域が同時故障しない限り、データを完全に喪失することを避けられます。しかし、片方のディスクが故障した場合は、できるだけ早くそのことを知って修理する必要があります。
drbd.confのon-io-error detachとPacemakerのdefault-resource-stickiness=200を組み合わせると、稼働系サーバのDRBDデータ領域の故障をPacemakerが検出できるようになります。そしてフェールオーバが起こり、パフォーマンス低下を避けられます。
さらにMailToリソースエージェントを組み込んでおくことによって、管理者は障害発生をメールで知ることができます。
ただし、待機系サーバのDRBDデータ領域が故障しても、フェールオーバは起こりません。したがって、実際のクラスタ運用にあたっては、DRBDの動作状態に関する何らかの外部監視と組み合わせることをお勧めします。


# 余談として


cluster1は十分な処理能力が持っているが、cluster2の処理能力に不安があるような場合、cluster1がダウンしている間のみcluster2を稼働系として使いたいでしょう。cluster1が復旧したら、cluster2からcluster1に自動的にフェールバックさせるという運用です。
詳しい説明は省略しますが、default-resource-stickiness=200を設定しておけば、location制約のスコアを2000程度に増やすことによって、自動フェールバックも実現できます。これも簡単に試せますので、ぜひ一度お試しください。
