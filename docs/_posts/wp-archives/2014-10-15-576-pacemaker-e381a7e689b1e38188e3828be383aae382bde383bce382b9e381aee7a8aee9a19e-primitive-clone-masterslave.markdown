---
author: t-matsuo
comments: false
date: 2014-10-15 05:30:15+00:00
layout: post
permalink: /wp/archives/576
slug: pacemaker-%e3%81%a7%e6%89%b1%e3%81%88%e3%82%8b%e3%83%aa%e3%82%bd%e3%83%bc%e3%82%b9%e3%81%ae%e7%a8%ae%e9%a1%9e-primitive-clone-masterslave
title: Pacemaker で扱えるリソースの種類 (Primitive, Clone, Master/Slave, Group)
wordpress_id: 576
categories:
- 読み物
tags:
- コラム
---

Pacemakerでは現在、Primitive, Clone, Master/Slave という大きく分けて3つの種類のリソース、および、PrimitiveをまとめたGroupというリソースを定義することができます。これらのリソースの違いについて簡単に説明します。

これらの概念は、Pacemaker-1.0系およびPacemaker-1.1系で共通です。


## Primitive


まず、一番よく使われるのがこの Primitive リソースです。これは全てのリソース定義の基礎になります。

これは、通常のAct-Standby構成で用いるリソースで、どこか一カ所のノードで動くことができます。よって、クラスタ全体のある1ノードだけで動いていればよいリソースに使用し、リソースが故障すれば、他のノードにフェールオーバーさせることができます。データベースやメールサーバのようなものをHAクラスタリングする場合は通常このリソースを定義することになります。

[![](/assets/images/wp-content/primitive.jpg)](/wp/archives/576/primitive)

 


## Clone


Cloneリソース は、Primitive リソースを複数のノードで動作させたい場合に使用します。そのため定義方法は、まずPrimitive を定義し、それをClone化するという流れになります。

あるアプリケーションを複数のノードで動かしたい場合、Primitiveだけで実現しようとすると、動かしたいノード数分だけ定義する必要がありますが、Cloneの場合は1つのCloneリソースを定義するだけで動かすことができます。

代表的な使用例として、ネットワークの疎通監視に使用するpingd リソースエージェント(以下RA) があります。ネットワーク越しにサービスを提供するAct-Standby 構成において、ActのPrimitiveリソースが故障し、Standby ノードにフェールオーバーしても、Standby ノードのネットワークが切れていては意味がありません。こういった事態を避けるために、pingd RA を全てのノードで動作させ、サービスを提供していないノードでもネットワークを監視し、ネットワークが故障してしまった場合は、そのノードにサービスがフェールオーバーしないようにするのが通常の使い方です。

なお、RAの実装としては、Primitive, Clone に違いはないため、動作が保証されているかは別として、Primitive で定義できる RAはClone化できます。

[![](/assets/images/wp-content/clone.jpg)](/wp/archives/576/clone)

 


## Master/Slave


Master/Slave リソースは、Clone リソースをさらに発展させたもので、Cloneリソースで親子の関係があるリソースに使用します。定義方法は、まずPrimitive を定義し、それをMaster/Slave化するという流れになります。

代表的な使用例としては、データのレプリケーションに使用するDRBD用のRA があります。DRBDでは、PrimaryとSecondaryと呼ばれる状態があり、Primaryではデータの読み書き、SecondaryではPrimaryからレプリケーション用のデータを受信し、ディスクに書き込みます。そのため、DRBDは複数のノードで動いている必要があり、さらにPrimaryとSecondaryの状態を区別する必要が出てきます。これをPacemakerのMaster/Slave を使って実現しています。

また、PostgreSQL用のRA(pgsql)で[ストリーミングレプリケーション](https://www.postgresql.jp/document/9.4/html/warm-standby.html#STREAMING-REPLICATION)を制御する際にもMaster/Slaveリソースを使用します。ストリ－ミングレプリケーションでは片方のPostgreSQLをMaster(読み書き可能)、もう片方をSlave(書き込み不可)とし、Masterに書き込まれたデータをSlaveに転送し続けることで、両系のデータを常に同じになるよう保っています。PostgreSQLのストリーミングレプリケーションとPacemaker(pgsql RA)を連携・制御する構成をPG-REXと呼称しています。詳細は[PG-REXコミュニティ(日本語)](https://osdn.jp/projects/pg-rex/)で。

なお、Master/Slave では、Primitive, Clone 用のRAに実装されている、start, stop というリソースの起動・停止操作に追加して、promote, demote という親に昇格、子どもに降格させる操作がRAに実装されている必要があるため、Primitive や Clone 用のRAをそのままMaster/Slave 化することはできません。

[![](/assets/images/wp-content/master_slave.jpg)](/wp/archives/576/master_slave)

 


## Group


Group リソースは、複数のPrimitiveリソースを１つのグループとしてまとめたリソースです。
同じグループとなったPrimitiveリソースは**必ず同じノード**で、**定義された順番に起動／停止**します。

Pacemaker内部の動作としては「colocation(同居)制約」と「order(順序)制約」の両制約をかけたのと同等です。
制約について詳しくは、[こちら](/wp/archives/3786)を参照ください。

[![group](/assets/images/wp-content/group.jpg)](/assets/images/wp-content/group.jpg)

 

 

 

 

 

 

 

 

 

 

 

 

 

 

<!-- more -->

以上、簡単に4つのリソースの種類について説明しました。

具体的な定義方法は、[動画デモ(part2の4分目) ](/wp/archives/441)や[過去のセミナ資料](/wp/archives/tag/osc)等を参考にしてみてください。
