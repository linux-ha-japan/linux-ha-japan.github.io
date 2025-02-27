---
author: bellche
comments: false
date: 2010-08-17 06:20:41+00:00
layout: post
permalink: /wp/archives/513
slug: linux-ha%e3%82%92gui%e3%81%a7%e7%ae%a1%e7%90%86%e3%80%8cdrbd-management-console%e3%80%8d
title: Linux-HAをGUIで管理「DRBD Management Console」
wordpress_id: 513
categories:
- 読み物
tags:
- DRBD
- DRBD-MC
---

## DRBD Management Consoleとは？





DRBD Management Console（以下：DMC）は、LINBIT社が開発してオープンソースソフトウェアとして公開しているLinux-HAのGUI管理ツールです。Javaで組まれているため、JREが導入されていれば、Windows、Mac、Linux等、様々なプラットホームで動作します。





### 何ができるの？





Linux-HA環境が構築されている環境に外部からアクセスして管理することができます。DMCはSSH経由で各サーバの状態を取得したり管理コマンドを発行するため、SSHで各ノードにアクセスできることが使用条件となります。なので、HA環境を組んでいるノードにエージェントのようなソフトウェアを導入しなくても使用することができるのでインターフェースにさえ慣れてしまえば便利に使うことができます。





開発途上のため、できることに制限はあるものの、クラスタ環境の管理、設定の追加・変更・削除、アクティブサーバの切り替え等、ちょっと使う分には問題無い程度に使用できます。





### まずはダウンロードして動かしてみよう





LINBIT社のOSSダウンロードページ（ [http://oss.linbit.com/drbd-mc/](http://oss.linbit.com/drbd-mc/) ）からソースやjarファイルがダウンロードできます。セキュリティに厳しいOSを使っている場合「どこからダウンロードしてきたJarファイルかわかんねーもん動かせねぇよ」とエラーを吐かれる場合がありますが、その場合はセキュリティレベルを落とすなり、root権限でコマンドラインから動かすなりどうにかして動かしてください。Jarファイルをダウンロードした場合には、以下のコマンドで起動できます。（できるはず）





注：OpenJDKでは画面がフリーズすることがありますので、Oracle JDKを使用してください。



<pre class="wp-caption" style="text-align: left;"># java -jar  DMC-0.7.9.jar</pre>




### インターフェースは慣れが必要





  






  




[caption id="attachment_517" align="alignright" width="300" caption="DRBD Management Console"][![](/assets/images/wp-content/dmc-if-300x213.png)](/assets/images/wp-content/dmc-if.png)[/caption]



  






  






右の画像はアクティブ／スタンバイ形式の簡単なLinux-HA環境にアクセスした所の画面です。





普通に思えるかもしれませんが、慣れが必要です。動かしてみるとよくわかりますが、いろいろつっこみどころ満載です。





基本的には３ペイン構成になってますが、左ペインのリソースやホスト等をクリックすると中央ペイン、右ペインの表示が切り替わります。





右ペインには設定値の変更だとか状態表示だとかが表示されています。まだ細かい設定まで出てこないので本格的に設定変更する場合には各ノードに直接ログインして手動で設定を変更するほうが良いです。





  






## まとめ





	
  * DRBDの管理も含めたLinux-HAの管理ツールは確かに存在する。

	
  * オレンジ色をどうにかしたいが、LINBITカラーなので仕方がないものとする。

	
  * 使い慣れると意外と日々の運用程度なら使える気がする。

	
  * 細かい設定はできないのと、設定間違えると消せなくなったりする時があるのでその辺は今後に期待。

	
  * HAの状態を見るには視覚的に見えるのと、関係が矢印表示されるので確認ツールとしては良い。

	
  * 日本語には対応していないので、日本語化をしたいと思う。


