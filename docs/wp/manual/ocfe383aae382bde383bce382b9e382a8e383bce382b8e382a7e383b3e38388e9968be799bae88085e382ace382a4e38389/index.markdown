---
author: ksk
comments: false
date: 2012-02-27 12:46:32+00:00
layout: page
permalink: /wp/manual/ocf%e3%83%aa%e3%82%bd%e3%83%bc%e3%82%b9%e3%82%a8%e3%83%bc%e3%82%b8%e3%82%a7%e3%83%b3%e3%83%88%e9%96%8b%e7%99%ba%e8%80%85%e3%82%ac%e3%82%a4%e3%83%89
published: false
slug: ocf%e3%83%aa%e3%82%bd%e3%83%bc%e3%82%b9%e3%82%a8%e3%83%bc%e3%82%b8%e3%82%a7%e3%83%b3%e3%83%88%e9%96%8b%e7%99%ba%e8%80%85%e3%82%ac%e3%82%a4%e3%83%89
title: OCFリソースエージェント開発者ガイド
wordpress_id: 2074
---

* * *

## はじめに

本書は、OCF（Open Cluster Framework）準拠のクラスタリソースエージェントに関して作業をしているすべての開発者、メンテナンス担当者および寄稿者に対するガイドおよびリファレンスとして機能します。本書は、リソースエージェントの構造や一般的機能を説明し、リソースエージェントAPIを説明し、リソースエージェント著者に効果的なヒントやヘルプを提供します。

### リソースエージェントとは何？

リソースエージェントは、クライアントリソースを管理する実行ファイルです。クラスタリソースに関しては、「クラスタが管理するものはすべてリソースである」という以外、正式な記述はありません。

クラスタリソースは、IPアドレス、ファイルシステム、データベースサービスおよび仮想マシン全体など多種多様なものとなっています。

### 誰がまたは何がリソースエージェントを使うのか？

OCF（Open Cluster Framework）に準拠したクラスタ管理アプリケーションなら、いずれのアプリケーションも、本書で説明されているリソースエージェントを使いリソースを管理することができます。本書の執筆時、Linuxプラットフォーム用に2つのOCF準拠クラスタ管理アプリケーションがあります。

  * _Pacemaker_ ：CorosyncおよびHeartbeatクラスタメッセージングフレームワークの両方をサポートするクラスタマネージャ。Pacemakerは、Linux-HAプロジェクトから進化し独立しています。 
  * _RGmanager_ ：Red Hat Cluster Suiteでバンドルされているクラスタマネージャ。これは、Corosyncクラスタメッセージングフレームワークだけをサポートします。 

### リソースエージェントはどの言語で記述されているのか？

OCF準拠リソースエージェントは _どのような_ プログラミング言語ででも実装可能です。APIは言語を問いません。しかし、ほとんどのリソースエージェントはshellスクリプトとして実装されています。本ガイドは、主にshell言語で記述されたサンプルコードを使います。

* * *

## API定義

### 環境変数

リソースエージェントは、環境変数を通じて、それが管理するリソースのすべての設定情報を受け取ります。これらの環境変数の名前は、常に、 OCF_RESKEY_ という接頭語が付いたリソースパラメータの名前となります。たとえば、リソースが、 192.168.1.1 に設定されている ip パラメータを持っている場合、リソースエージェントは、その値を保持する OCF_RESKEY_ip 環境変数にアクセスできます。ユーザによって設定される必要のないリソースパラメータに対しては、つまり、リソースエージェントメタデータでのそのパラメータ定義は required="true" を指定しませんが、リソースエージェントは以下を行う必要があります。

  * 適切なデフォルトを提供する。これは、メタデータで宣言される必要があります。慣例により、リソースエージェントは、このデフォルトを保持する OCF_RESKEY_<parametername>_default と名付けられた変数を使います。 
  * あるいは、空値に対して正しく対処する。 

さらに、クラスタマネージャは、 _meta_ リソースパラメータもサポートします。これらは、リソース設定には直接適用されませんが、クラスタリソースマネージャが _どのように_ リソースを管理するかが指定されます。たとえば、Pacemakerクラスタマネージャは、リソースが起動されるべきか停止されるべきかを指定するために、 target-role metaパラメータを使います。

metaパラメータは OCF_RESKEY_CRM_meta_ 名前空間でリソースエージェントに渡されます。（この場合、ハイフンはアンダースコアに変換されます）。したがって、 target-role 属性は OCF_RESKEY_CRM_meta_target_role と名付けられた環境変数にマッピングされます。

### アクション

いずれのリソースエージェントも1つのコマンドライン引数をサポートしなければなりません。これは、リソースエージェントが実行しようとしているアクションを指定します。以下のアクションはいずれのリソースエージェントによってサポートされなければなりません。

  * start — リソースを起動します。 
  * stop — リソースを停止します。 
  * monitor — リソースの状態を問合せします。 
  * meta-data — リソースエージェントメタデータをダンプします。 さらに、リソースエージェントは、以下のアクションをオプションとしてサポートします。 
  * promote — リソースを Master 役割に変更します（Master/Slaveリソースのみ）。 
  * demote — リソースを Slave 役割に変更します（Master/Slaveリソースのみ）。 
  * migrate_to および migrate_from — リソースのライブマイグレーションを実施します。 
  * validate-all --リソースの設定を検証します。 
  * usage or help — リソースエージェントがコマンドラインから起動される場合に、クライアントメッセージの代わり使用メッセージを表示します。 
  * status —  monitor に対する歴史的（旧）同義語。 

### タイムアウト

アクションのタイムアウトは、リソースエージェントの範囲外で実施されます。リソースエージェントアクションがどれぐらいの時間実行されているかを監視し、その終了時間にアクションが終了しない場合には、そのアクションを停止するのはクラスタマネージャの責任です。したがって、リソースエージェント自身は、タイムアウトをチェックする必要はありません。しかし、リソースエージェントは、適切なタイムアウト値（正しく設定されれば、クラスタマネージャによって正しく実行される）をユーザに_忠告_することができます。リソースエージェントが、その提案されたタイムアウトをどのように忠告するかについては以下のセクションを参照してください。

### メタデータ

それぞれのリソースエージェントは、一連のXML メタデータで自分自身の目的とサポートされているパラメータを記述しなければなりません。このメタデータは、オンラインヘルプに対して、クラスタ管理アプリケーションによって使われ、リソースエージェントのmanページもそれから生成されます。以下は、架空のリソースエージェントからの一連の仮想メタデータです。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000080"><?xml</font></b> <font color="#009900">version</font><font color="#990000">=</font><font color="#FF0000">"1.0"</font><b><font color="#000080">?></font></b>
<b><font color="#000080"><!DOCTYPE</font></b> <font color="#009900">resource</font>-<font color="#009900">agent</font> <font color="#009900">SYSTEM</font> <font color="#FF0000">"ra-api-1.dtd"</font><b><font color="#000080">></font></b>
<b><font color="#0000FF"><resource-agent</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"foobar"</font> <font color="#009900">version</font><font color="#990000">=</font><font color="#FF0000">"0.1"</font><b><font color="#0000FF">></font></b>
  <b><font color="#0000FF"><version></font></b>0.1<b><font color="#0000FF"></version></font></b>
  <b><font color="#0000FF"><longdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>
This is a fictitious example resource agent written for the
OCF Resource Agent Developers Guide.
  <b><font color="#0000FF"></longdesc></font></b>
  <b><font color="#0000FF"><shortdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>Example resource agent
  for budding OCF RA developers<b><font color="#0000FF"></shortdesc></font></b>
  <b><font color="#0000FF"><parameters></font></b>
    <b><font color="#0000FF"><parameter</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"eggs"</font> <font color="#009900">unique</font><font color="#990000">=</font><font color="#FF0000">"0"</font> <font color="#009900">required</font><font color="#990000">=</font><font color="#FF0000">"1"</font><b><font color="#0000FF">></font></b>
      <b><font color="#0000FF"><longdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>
      Number of eggs, an example numeric parameter
      <b><font color="#0000FF"></longdesc></font></b>
      <b><font color="#0000FF"><shortdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>Number of eggs<b><font color="#0000FF"></shortdesc></font></b>
      <b><font color="#0000FF"><content</font></b> <font color="#009900">type</font><font color="#990000">=</font><font color="#FF0000">"integer"</font><b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"></parameter></font></b>
    <b><font color="#0000FF"><parameter</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"superfrobnicate"</font> <font color="#009900">unique</font><font color="#990000">=</font><font color="#FF0000">"0"</font> <font color="#009900">required</font><font color="#990000">=</font><font color="#FF0000">"0"</font><b><font color="#0000FF">></font></b>
      <b><font color="#0000FF"><longdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>
      Enable superfrobnication, an example boolean parameter
      <b><font color="#0000FF"></longdesc></font></b>
      <b><font color="#0000FF"><shortdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>Enable superfrobnication<b><font color="#0000FF"></shortdesc></font></b>
      <b><font color="#0000FF"><content</font></b> <font color="#009900">type</font><font color="#990000">=</font><font color="#FF0000">"boolean"</font> <font color="#009900">default</font><font color="#990000">=</font><font color="#FF0000">"false"</font><b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"></parameter></font></b>
    <b><font color="#0000FF"><parameter</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"datadir"</font> <font color="#009900">unique</font><font color="#990000">=</font><font color="#FF0000">"0"</font> <font color="#009900">required</font><font color="#990000">=</font><font color="#FF0000">"1"</font><b><font color="#0000FF">></font></b>
      <b><font color="#0000FF"><longdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>
      Data directory, an example string parameter
      <b><font color="#0000FF"></longdesc></font></b>
      <b><font color="#0000FF"><shortdesc</font></b> <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><b><font color="#0000FF">></font></b>Data directory<b><font color="#0000FF"></shortdesc></font></b>
      <b><font color="#0000FF"><content</font></b> <font color="#009900">type</font><font color="#990000">=</font><font color="#FF0000">"string"</font><b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"></parameter></font></b>
  <b><font color="#0000FF"></parameters></font></b>
  <b><font color="#0000FF"><actions></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"start"</font>        <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"stop"</font>         <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"monitor"</font>      <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font>
                                <font color="#009900">interval</font><font color="#990000">=</font><font color="#FF0000">"10"</font> <font color="#009900">depth</font><font color="#990000">=</font><font color="#FF0000">"0"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"reload"</font>       <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"migrate_to"</font>   <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"migrate_from"</font> <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"meta-data"</font>    <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"5"</font> <b><font color="#0000FF">/></font></b>
    <b><font color="#0000FF"><action</font></b> <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"validate-all"</font>   <font color="#009900">timeout</font><font color="#990000">=</font><font color="#FF0000">"20"</font> <b><font color="#0000FF">/></font></b>
  <b><font color="#0000FF"></actions></font></b>
<b><font color="#0000FF"></resource-agent></font></b></tt></pre>

</td></tr></table>
 

resource-agent 要素はリソースエージェント毎に1つだけ設定される必要があり、リソースエージェントの name と version を定義します。

resource-agent の longdesc と shortdesc 要素は、リソースエージェントの機能のlong説明とshort説明を設定します。 shortdesc は、リソースエージェントが何をするかの説明（1行）で、通常、簡単なリストで使われます。それに対して longdesc は、リソースエージェントを出来るだけ詳細に説明します。

parameters 要素はリソースエージェントのパラメータを説明し、リソースエージェントがサポートするそれぞれのパラメータに対し て parameter 要素をいくつも持ちます。

それぞれの parameter は、全体的に resource-agent のように、 shortdesc と longdesc と共に設定され、また、パラメータの期待される内容を記述す る content 要素と共に設定されます。

content 要素では、4種類の属性が設定されます。

  * type はパラメータタイプ（ string , integer , boolean ）を設定します。デフォルト： string
  * required はパラメータ設定が必須（ required="true" ）であるかオプション( required="false" )であるかを設定します。 
  * オプションパラメータに関しては、default属性を通じて適切なデフォルトを提供してください。 
  * 最後に、 unique 属性（許容値： true 、 false ）は、この特定のリソースタイプのこのパラメータに対してその特定値がクラスタ全体で一意となる必要があることを示します。たとえば、特に多く使われるフローティングIPアドレスは unique として宣言され、1つのIPアドレスは、クラスタを通じて1回しか使用できません。 

actions リストは、リソースエージェントが「サポートされている」と宣伝するアクションを定義します。

それぞれの action は、自分自身の timeout 値をリストします。これは、アクションに対してどのような_最小_タイムアウトが設定されるべきかというユーザに対するヒントとなります。これは、特定のリソース（例：IPアドレスやファイルシステム）はすばやく起動／停止できたり、他のリソース（例：データベース）は数分かかったりするのに対応するためです。

さらに、繰り返しアクション（例： monitor ）は、最低推奨 interval も指定する必要があります。 interval は、同じアクションが2回続けて起動される場合の間隔を指定します。 timeout のように、この値はデフォルト設定できません。これは、どのような最低アクション間隔を設定すればいいかというユーザへのヒントにすぎません。

* * *

## 戻り値

アクションが起動されたら、リソースエージェントは、定義された戻り値で終了しなければなりません。戻り値は、起動されたアクションの結果を呼出側に通知します。戻り値は以下の項で詳細が説明されています。

### OCF_SUCCESS (0)

アクションは正しく終了しています。これは、正しく終了したアクション（ start , stop , promote , demote , migrate_from , migrate_to , meta_data , help および usage ）に対する戻り値となります。しかし、 monitor （ status ：旧エイリアス）に関しては、変更された規定が適用されます。

  * primitive (stateless)リソースに関しては、 monitor からの OCF_SUCCESS は、リソースが実行されていることを意味します。実行されておらず正しく停止されたリソースは、 OCF_NOT_RUNNING を返す必要があります。 
  * master/slave (stateful)リソースに関しては、 monitor からの OCF_SUCCESS は、リソースが _Slaveモードで_ 実行されていることを意味します。Masterモード実行されているリソースは OCF_RUNNING_MASTER を返す必要があり、正しく停止されたリソースは OCF_NOT_RUNNING を返す必要があります。 

### OCF_ERR_GENERIC (1)

アクションは汎用エラーを返しています。以下に定義された具体的なエラーコードが、いずれも問題を記述していない場合にのみ、リソースエージェントこの終了コードでアクションを終了する必要があります。

クラスタリソースマネージャは、この終了コードを_ソフト_エラーとして解釈します。これは、具体的に設定されていない限り、リソースマネージャは、同じノードのリソースを再起動することによってインプレース のOCF_ERR_GENERIC で失敗したリソースをリカバリしようとします。

### OCF_ERR_ARGS (2)

リソースエージェントは正しくない引数で起動されました。これは、「あってはならない」エラーに対する安全策で、リソースエージェントは、たとえば、正しくない数のコマンドライン引数で起動されたような場合にのみに返すべきです。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >リソースエージェントは、サポートしていないアクションを実行するよう指示された場合、このエラーを返すべきではありません。その代わり、そのような状況では、OCF_ERR_UNIMPLEMENTEDを返すべきです。
</td></tr></table>

### OCF_ERR_UNIMPLEMENTED (3)

リソースエージェントは、エージェントが設定していないアクションを実行するよう指示されました。

すべてのリソースエージェントが必須となっているわけではありません。リソースエージェントはそれらを設定しているかしていな いpromote , demote , migrate_to , migrate_from および notify はすべてオプショナルのアクションです。non-statefulリソースエージェントが、たとえば、まちがってmaster/slaveリソースに設定された場合、リソースエージェントは、 promote および demote アクションで、 OCF_ERR_UNIMPLEMENTED を返してこの設定エラーについてユーザに警告するべきです。

### OCF_ERR_PERM (4)

アクションは、不十分なアクセス権限により失敗しました。これは、エージェントが特定のファイルを開くことができなかったり、特定のソケットでlistenできなかったり、ディレクトリに書き込みができなかったりしたことによるものです。

クライアントリソースマネージャは、この終了コードを _ハード_エラーとして解釈します。この場合、具体的に設定されていないかぎり、リソースマネージャは、異なるノード（アクセス権限に関する問題がない）でリソースを再起動することにより、このエラーで故障したリソースをリカバリしようとします。

### OCF_ERR_INSTALLED (5)

アクションは、それが実行されたノードに必要コンポーネントがなかったために失敗しました。これは、必要バイナリが実行可能ではなかった、あるいは、重要な設定ファイルが「読めない」ことによるものです。

クラスタマネージャは、この終了コードを _ハード_ エラーとして解釈します。

この場合、具体的に設定されていないかぎり、リソースマネージャは、異なるノード（必要ファイルやバイナリがある）でリソースを再起動することにより、このエラーで故障したリソースをリカバリしようとします。

### OCF_ERR_CONFIGURED (6)

アクションは、ユーザがリソースを正しく設定しなかったために失敗しました。たとえば、ユーザが、整数パラメータに英数字文字列を設定したような場合です。

クラスタリソースマネージャは、この終了コードを _致命的_ エラーとして解釈します。これはクラスタ全体の設定エラーであるため、インプレースのノードではもちろんのこと、異なるノードでそのようなリソースをリカバリするのは意味がありません。リソースがこのエラーで故障すると、クラスタマネージャは、リソースを停止しようとし、管理者の介入を待ちます。

### OCF_NOT_RUNNING (7)

リソースは実行されていないことが判明しました。これは、 monitor アクションのみによって返される終了コードです。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >これはリソースが _正しく_ 終了されているか、そもそも起動されていなかったことを意味します。
</td></tr></table>

リソースがエラー状態のせいで実行されていない場合、 monitor アクションは、代わりに OCF_ERR_ 終了コードの一つか、 OCF_FAILED_MASTER を返すべきです。

### OCF_RUNNING_MASTER (8)

リソースは、 Master roleで実行されていると判明しました。これはstateful (Master/Slave)リソースにのみ適用され、そして、それらの monitor アクションにのみ適用されます。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >"slaveモードでの実行"に対しては特定の終了コードはありません。これは、通常に実行されているprimitiveリソースと、slaveとして実行されているstatefulリソースの間の区別がないからです。 Slave roleで通常に実行されているstatefulリソース のmonitor アクションは OCF_SUCCESS を返します。
</td></tr></table>

### OCF_FAILED_MASTER (9)

リソースは Master roleで故障していると判明しました。これはstateful (Master/Slave)リソースにのみ適用され、そして、それらの monitor アクションにのみ適用されます。

クラスタリソースマネージャは、この終了コードを_ソフト_ エラーとして解釈します。この場合、リソースマネージャは、具体的に設定されていないかぎり、インプレースの $OCF_FAILED_MASTER で故障したリソースをリカバリしようとします。これは、通常、同じノードのリソースを格下げしたり、停止したり、起動したり、そして、プロモートしたりして行います。

* * *

## リソースエージェントの構造

典型的（shellベース）のリソースエージェントは、本項でリストされた順序で標準の構成要素を持っています。それらの構成要素は、 foobar と名付けられた仮想リソースエージェントを例として使い、リソースエージェントの期待される動作を、それがサポートする各種のアクションに関して記述します。

### リソースエージェントインタプリタ

スクリプトとして実装されたリソースは、標準の"shebang" (#!)ヘッダ構文を使い、そのインタプリタを指定しなければなりません。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>#!/bin/sh</pre>


 
</td></tr> </table>

リソースエージェントがshellで記述されている場合、必須ではありませんが汎用shellインタプリタを指定してください。 /bin/sh 互換として宣言されたリソースエージェントは、特定のshellにネイティブな構文（例 ：bash にネイティブな ${!variable} 構文）を使用できません。必要に応じて、 checkbashisms などのsanitizationユーティリティを使い、そのようなリソースエージェントを実行してください。

それまでは sh 互換であったリソースエージェントが bash 、 ksh あるいは他の非汎用shellにのみにしか互換性がないようにするパッチはリグレッションであると考えます。しかし、新しいリソースエージェントが、 /bin/bash といった特定のshellをインタプリタとして明示的に定義することはまったく問題ありません。

### 著者およびライセンス情報

リソースエージェントは、リソースエージェントの著者や著作権保持者、そして、リソースエージェントに適用されるライセンスを記載したコメントを記述する必要があります。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><i><font color="#9A1900">#</font></i>
<i><font color="#9A1900">#   Resource Agent for managing foobar resources.</font></i>
<i><font color="#9A1900">#</font></i>
<i><font color="#9A1900">#   License:      GNU General Public License (GPL)</font></i>
<i><font color="#9A1900">#   (c) 2008-2010 John Doe, Jane Roe,</font></i>
<i><font color="#9A1900">#                 and Linux-HA contributors</font></i></tt></pre>

</td></tr></table>
 

リソースエージェントが、複数のバージョンに対するライセンスを参照する場合、それはその時点のバージョンが対象であると前提します。

### 初期化

どのようなshellリソースエージェントも、 .ocf-shellfuncs 関数ライブラリをソースとしなければなりません。これは、以下の構文を使って、 $OCF_FUNCTIONS_DIR で行うことができます。 $OCF_FUNCTIONS_DIR は、テスト目的およびドキュメンテーションの生成に対して、コマンドラインから上書きされます。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><i><font color="#9A1900"># Initialization:</font></i>
<font color="#990000">:</font> <font color="#009900">${OCF_FUNCTIONS_DIR=${OCF_ROOT}/resource.d/heartbeat}</font>
<font color="#990000">.</font> <font color="#009900">${OCF_FUNCTIONS_DIR}</font><font color="#990000">/.</font>ocf-shellfuncs</tt></pre>

</td></tr></table>
 

リソースエージェントパラメータのデフォルトは、 _default 接尾語で変数を初期化することにより設定されるべきです。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><i><font color="#9A1900"># Defaults</font></i>
<font color="#009900">OCF_RESKEY_superfrobnicate_default</font><font color="#990000">=</font><font color="#993399">0</font>

<font color="#990000">:</font> <font color="#009900">${OCF_RESKEY_superfrobnicate=${OCF_RESKEY_superfrobnicate_default}}</font></tt></pre>

</td></tr></table>
 <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >リソースエージェントは、メタデータで required と指定されていないパラメータに対してデフォルトを設定しなければなりません。
</td></tr></table>

### リソースエージェントアクションを実装する関数

以下に、リソースエージェントのアクション（宣伝された）を実装する関数が説明されています。個々のアクションはリソースエージェントアクションで詳細が説明されています。

### 実行ブロック

これは、リソースエージェントの一部で、リソースエージェントが起動された場合に実際に実行される部分です。これは、大体において標準的な構造となっています。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><i><font color="#9A1900"># Make sure meta-data and usage always succeed</font></i>
<b><font color="#0000FF">case</font></b> <font color="#009900">$__OCF_ACTION</font> <b><font color="#0000FF">in</font></b>
meta-data<font color="#990000">)</font>      foobar_meta_data
                <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_SUCCESS</font>
                <font color="#990000">;;</font>
usage<font color="#990000">|</font><b><font color="#0000FF">help</font></b><font color="#990000">)</font>     foobar_usage
                <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_SUCCESS</font>
                <font color="#990000">;;</font>
<b><font color="#0000FF">esac</font></b>

<i><font color="#9A1900"># Anything other than meta-data and usage must pass validation</font></i>
foobar_validate <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

<i><font color="#9A1900"># Translate each action into the appropriate function call</font></i>
<b><font color="#0000FF">case</font></b> <font color="#009900">$__OCF_ACTION</font> <b><font color="#0000FF">in</font></b>
start<font color="#990000">)</font>          foobar_start<font color="#990000">;;</font>
stop<font color="#990000">)</font>           foobar_stop<font color="#990000">;;</font>
status<font color="#990000">|</font>monitor<font color="#990000">)</font> foobar_monitor<font color="#990000">;;</font>
promote<font color="#990000">)</font>        foobar_promote<font color="#990000">;;</font>
demote<font color="#990000">)</font>         foobar_demote<font color="#990000">;;</font>
reload<font color="#990000">)</font>         ocf_log info <font color="#FF0000">"Reloading..."</font>
                foobar_start
                <font color="#990000">;;</font>
validate-all<font color="#990000">)</font>   <font color="#990000">;;</font>
<font color="#990000">*)</font>              foobar_usage
                <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_UNIMPLEMENTED</font>
                <font color="#990000">;;</font>
<b><font color="#0000FF">esac</font></b>
<font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$?</font>

<i><font color="#9A1900"># The resource agent may optionally log a debug message</font></i>
ocf_log debug <font color="#FF0000">"${OCF_RESOURCE_INSTANCE} $__OCF_ACTION returned $rc"</font>
<b><font color="#0000FF">exit</font></b> <font color="#009900">$rc</font></tt></pre>

</td></tr></table>
 

* * *

## リソースエージェントアクション

それぞれのアクションは、通常、リソースエージェントの別々の関数やメソッドで実装されています。規定では、これらは、通常、 <agent>_<action> というように名前が付けられています。したがって、 foobar に start アクションを実装する関数は、 foobar_start() というような名前が付けられます。

原則として、 リソースエージェントが致命的なエラーに遭遇した場合、ただちに終了し、例外を出力したり、そうでなければ停止することが許可されています。この例としては設定問題、バイナリのないこと、アクセス権限に関する問題などがあります。また、これらのエラーはコールスタックに渡す必要はありません。

この場合、ユーザの設定に基づいて適切なリカバリアクションを起動するのはクラスタマネージャの責任です。リソースエージェントは、その設定に対しては何も推定するべきではありません。

### start アクション

リソースエージェントは、 start アクションで起動されると、リソースを起動しなければなりません（すでに実行されていない場合）。このことは、エージェントは、リソースの設定を検証し、その状態を問合せし、もしそのリソースが実行されていない場合にのみ、そのリソースを起動する必要があります。これを行う一般的な方法は、以下の例で示されているように、 validate_all および monitor 関数を最初に起動することになるでしょう。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_start()</font></b> {
    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># if resource is already running, bail out early</font></i>
    <b><font color="#0000FF">if</font></b> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
        ocf_log info <font color="#FF0000">"Resource is already running"</font>
        <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
    <b><font color="#0000FF">fi</font></b>

    <i><font color="#9A1900"># actually start up the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    <font color="#990000">...</font>

    <i><font color="#9A1900"># After the resource has been started, check whether it started up</font></i>
    <i><font color="#9A1900"># correctly. If the resource starts asynchronously, the agent may</font></i>
    <i><font color="#9A1900"># spin on the monitor function here -- if the resource does not</font></i>
    <i><font color="#9A1900"># start up within the defined timeout, the cluster manager will</font></i>
    <i><font color="#9A1900"># consider the start action failed</font></i>
    <b><font color="#0000FF">while</font></b> <font color="#990000">!</font> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        ocf_log debug <font color="#FF0000">"Resource has not started yet, waiting"</font>
        sleep <font color="#993399">1</font>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

### stop アクション

リソースエージェントは、 stop アクションで起動された場合、リソース（実行されている場合）を停止しなければなりません。このことは、エージェントはリソースの設定を検証し、その状態を問合せし、そして、それがその時点で実行されている場合にのみ、そのリソースを停止しなければならないことを意味します。これを行う一般的な方法は、以下の例で示されているように、 validate_all およ び monitor 関数を最初に起動することです。ここで覚えておかなければならないのは、 stop は強制的なオペレーションであるということです。リソースエージェントは、その権限の範囲内でリソース（ノードをリブートしたり停止したりできない）を停止する必要があります。以下の例を見てください。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_stop()</font></b> {
    <b><font color="#0000FF">local</font></b> rc

    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    foobar_monitor
    <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$?</font>
    <b><font color="#0000FF">case</font></b> <font color="#FF0000">"$rc"</font> <b><font color="#0000FF">in</font></b><font color="#990000">)</font>
        <font color="#FF0000">"$OCF_SUCCESS"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Currently running. Normal, expected behavior.</font></i>
            ocf_log debug <font color="#FF0000">"Resource is currently running"</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">"$OCF_RUNNING_MASTER"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Running as a Master. Need to demote before stopping.</font></i>
            ocf_log info <font color="#FF0000">"Resource is currently running as Master"</font>
            foobar_demote <font color="#990000">||</font> <font color="#990000">\</font>
                ocf_log warn <font color="#FF0000">"Demote failed, trying to stop anyway"</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">"$OCF_NOT_RUNNING"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Currently not running. Nothing to do.</font></i>
            ocf_log info <font color="#FF0000">"Resource is already stopped"</font>
            <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
            <font color="#990000">;;</font>
    <b><font color="#0000FF">esac</font></b>

    <i><font color="#9A1900"># actually shut down the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    <font color="#990000">...</font>

    <i><font color="#9A1900"># After the resource has been stopped, check whether it shut down</font></i>
    <i><font color="#9A1900"># correctly. If the resource stops asynchronously, the agent may</font></i>
    <i><font color="#9A1900"># spin on the monitor function here -- if the resource does not</font></i>
    <i><font color="#9A1900"># shut down within the defined timeout, the cluster manager will</font></i>
    <i><font color="#9A1900"># consider the stop action failed</font></i>
    <b><font color="#0000FF">while</font></b> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        ocf_log debug <font color="#FF0000">"Resource has not stopped yet, waiting"</font>
        sleep <font color="#993399">1</font>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>

}</tt></pre>

</td></tr></table>
 <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >正しいstopオペレーションに対して期待される終了コードは $OCF_SUCCESS です（ $OCF_NOT_RUNNING ではありません）。
</td></tr></table> <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Important_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >失敗したstopオペレーションは危険な状況を生み出す可能性があります。つまり、クラスタマネージャは、ノードを隔離（fencing）することにより問題を解決しようとし、stopオペレーションが失敗したノードをクラスタから強制的に排除します。しかし、最終的にはこの方法はデータを保護しますが、アプリケーションやそれらのユーザに混乱を引き起こします。したがって、リソースエージェントは、適切なリソース停止手段がすべて実行し尽した場合にのみ、エラーで終了する必要があります。
</td></tr></table>

### monitor アクション

monitor アクションは、リソースのその時点の状態を問合せし、3種類の状態をそれぞれ識別しなければなりません。

  * リソースがその時点で実行されています（ $OCF_SUCCESS を返します） 
  * リソースは正しく停止されています（ $OCF_NOT_RUNNING を返します） 
  * リソースはエラーに遭遇したため失敗したと認識されます（エラーを示す適切な $OCF_ERR_ コードを返します。） 
<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_monitor()</font></b> {
    <b><font color="#0000FF">local</font></b> rc

    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    ocf_run frobnicate --test

    <i><font color="#9A1900"># This example assumes the following exit code convention</font></i>
    <i><font color="#9A1900"># for frobnicate:</font></i>
    <i><font color="#9A1900"># 0: running, and fully caught up with master</font></i>
    <i><font color="#9A1900"># 1: gracefully stopped</font></i>
    <i><font color="#9A1900"># any other: error</font></i>
    <b><font color="#0000FF">case</font></b> <font color="#FF0000">"$?"</font> <b><font color="#0000FF">in</font></b>
        <font color="#993399">0</font><font color="#990000">)</font>
            <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$OCF_SUCCESS</font>
            ocf_log debug <font color="#FF0000">"Resource is running"</font>
            <font color="#990000">;;</font>
        <font color="#993399">1</font><font color="#990000">)</font>
            <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$OCF_NOT_RUNNING</font>
            ocf_log debug <font color="#FF0000">"Resource is not running"</font>
            <font color="#990000">;;</font>
        <font color="#990000">*)</font>
            ocf_log err <font color="#FF0000">"Resource has failed"</font>
            <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
    <b><font color="#0000FF">esac</font></b>

    <b><font color="#0000FF">return</font></b> <font color="#009900">$rc</font>
}</tt></pre>

</td></tr></table>
 

Stateful (master/slave)リソースエージェントは、より高度な監視機構を使い、 Master roleを引き受けるのにどのインスタンスが最適であるかを識別するヒントをクラスタマネージャに提供することができます。 詳細はmasterプリファレンスを指定するで説明されています。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >クラスタマネージャは、 _probe_ に対して monitor アクションを起動し、リソースがその時点で実行されているかどうかをテストします。通常、monitorオペレーションは、probeおよび「実際の」monitorアクションの間、まったく同じように機能します。しかし、特定のリソースが、probesに対して特別な処理を行う場合、その目的のために ocf_is_probe 簡易関数がOCF shell関数ライブラリで提供されています。
</td></tr></table>

### validate-all アクション

validate-all アクションは、正しいリソースエージェント設定と作業環境をテストします。 validate-all は、以下のいずれかの戻り値になければなりません。

  * $OCF_SUCCESS — すべてが正しく機能しており、設定も正しく使用可能となっています。 
  * $OCF_ERR_CONFIGURED — ユーザはリソースを正しく設定していません。 
  * $OCF_ERR_INSTALLED — リソースは正しく設定されているように思われますが、 validate-all が実行されているノードには重要な部分（コンポーネント）がありません。 
  * $OCF_ERR_PERM — リソースは正しく設定されており、必要部分（コンポーネント）もすべてありますが、アクセス権限に関するエラー（例：必要ファイルが作成できない）により問題が生じています。 

validate-all は、通常、関数で定義されています。この関数は、対応するアクションが明示的に起動される場合にしか呼び出されませんが、sanityチェックのように、他のほとんどの関数からも呼び出し可能となっています。したがって、リソースエージェントの著者は、関数が start , stop ,および monitor オペレーション中に起動され、また、probes中にも起動されることを考慮しなければなりません。

Probesは、検証にあらたな問題を提議します。probe中（クラスタマネージャが、probe実行ノードでリソースが _起動されていない _と予測する場合）、いくつかの必要部分（コンポーネント）は、影響を受けるノードでは使用不可能となると_予測される_かもしれません。たとえば、これには、probe中の読み込みには提供されないストレージデバイスの共有データが含まれます。したがって validate-all 関数は、 ocf_is_probe 簡易関数を使って、probesを特別に取り扱う必要があります。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_validate_all()</font></b> {
    <i><font color="#9A1900"># Test for configuration errors first</font></i>
    <b><font color="#0000FF">if</font></b> <font color="#990000">!</font> ocf_is_decimal <font color="#009900">$OCF_RESKEY_eggs</font><font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
       ocf_log err <font color="#FF0000">"eggs is not numeric!"</font>
       <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_CONFIGURED</font>
    <b><font color="#0000FF">fi</font></b>

    <i><font color="#9A1900"># Test for required binaries</font></i>
    check_binary frobnicate

    <i><font color="#9A1900"># Check for data directory (this may be on shared storage, so</font></i>
    <i><font color="#9A1900"># disable this test during probes)</font></i>
    <b><font color="#0000FF">if</font></b> <font color="#990000">!</font> ocf_is_probe<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
       <b><font color="#0000FF">if</font></b> <font color="#990000">!</font> <font color="#990000">[</font> -d <font color="#009900">$OCF_RESKEY_datadir</font> <font color="#990000">];</font> <b><font color="#0000FF">then</font></b>
          ocf_log err <font color="#FF0000">"$OCF_RESKEY_datadir does not exist or is not a directory!"</font>
          <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_INSTALLED</font>
       <b><font color="#0000FF">fi</font></b>
    <b><font color="#0000FF">fi</font></b>

    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

### meta-data アクション

meta-data アクションは、リソースエージェントメタデータを標準出力にダンプします。出力は、メタデータで指定されているようにメタデータフォーマットに準拠する必要があります。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt>foobar_meta_data {
    cat <font color="#990000"><<</font>EOF
<font color="#990000"><?</font>xml <font color="#009900">version</font><font color="#990000">=</font><font color="#FF0000">"1.0"</font><font color="#990000">?></font>
<font color="#990000"><!</font>DOCTYPE resource-agent SYSTEM <font color="#FF0000">"ra-api-1.dtd"</font><font color="#990000">></font>
<font color="#990000"><</font>resource-agent <font color="#009900">name</font><font color="#990000">=</font><font color="#FF0000">"foobar"</font> <font color="#009900">version</font><font color="#990000">=</font><font color="#FF0000">"0.1"</font><font color="#990000">></font>
  <font color="#990000"><</font>version<font color="#990000">></font><font color="#993399">0.1</font><font color="#990000"><</font>/version<font color="#990000">></font>
  <font color="#990000"><</font>longdesc <font color="#009900">lang</font><font color="#990000">=</font><font color="#FF0000">"en"</font><font color="#990000">></font>
<font color="#990000">...</font>
EOF
}</tt></pre>

</td></tr></table>
 

### promote アクション

promote アクションはオプショナルとなっています。これは、 _stateful_ リソースエージェントによってのみサポートされなければなりません。このことは、エージェントは Master  と Slave という2つの個別の役割（role）を識別しなければならないことを意味します。 Slave は、statelessリソースエージェントでの Started 状態と機能的には同じです。したがって、通常（stateless）のリソースエージェントは、 start および stop のみを実装しなければなりませんが、statefulリソースエージェントは、 Started ( Slave ）および Master の役割（role）の間での遷移を可能にするため、 promote アクションもサポートしなければなりません。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_promote()</font></b> {
    <b><font color="#0000FF">local</font></b> rc

    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># test the resource's current state</font></i>
    foobar_monitor
    <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$?</font>
    <b><font color="#0000FF">case</font></b> <font color="#FF0000">"$rc"</font> <b><font color="#0000FF">in</font></b><font color="#990000">)</font>
        <font color="#FF0000">"$OCF_SUCCESS"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Running as slave. Normal, expected behavior.</font></i>
            ocf_log debug <font color="#FF0000">"Resource is currently running as Slave"</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">"$OCF_RUNNING_MASTER"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Already a master. Unexpected, but not a problem.</font></i>
            ocf_log info <font color="#FF0000">"Resource is already running as Master"</font>
            <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">"$OCF_NOT_RUNNING"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Currently not running. Need to start before promoting.</font></i>
            ocf_log info <font color="#FF0000">"Resource is currently not running"</font>
            foobar_start
            <font color="#990000">;;</font>
        <font color="#990000">*)</font>
            <i><font color="#9A1900"># Failed resource. Let the cluster manager recover.</font></i>
            ocf_log err <font color="#FF0000">"Unexpected error, cannot promote"</font>
            <b><font color="#0000FF">exit</font></b> <font color="#009900">$rc</font>
            <font color="#990000">;;</font>
    <b><font color="#0000FF">esac</font></b>

    <i><font color="#9A1900"># actually promote the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    ocf_run frobnicate --master-mode <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>

    <i><font color="#9A1900"># After the resource has been promoted, check whether the</font></i>
    <i><font color="#9A1900"># promotion worked. If the resource promotion is asynchronous, the</font></i>
    <i><font color="#9A1900"># agent may spin on the monitor function here -- if the resource</font></i>
    <i><font color="#9A1900"># does not assume the Master role within the defined timeout, the</font></i>
    <i><font color="#9A1900"># cluster manager will consider the promote action failed.</font></i>
    <b><font color="#0000FF">while</font></b> <b><font color="#0000FF">true</font></b><font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        foobar_monitor
        <b><font color="#0000FF">if</font></b> <font color="#990000">[</font> <font color="#009900">$?</font> -eq <font color="#009900">$OCF_RUNNING_MASTER</font> <font color="#990000">];</font> <b><font color="#0000FF">then</font></b>
            ocf_log debug <font color="#FF0000">"Resource promoted"</font>
            <b><font color="#0000FF">break</font></b>
        <b><font color="#0000FF">else</font></b>
            ocf_log debug <font color="#FF0000">"Resource still awaiting promotion"</font>
            sleep <font color="#993399">1</font>
        <b><font color="#0000FF">fi</font></b>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

### demote アクション

demote アクションはオプショナルです。これは、 _stateful_ リソースエージェントによってのみサポートされる必要があります。このことは、エージェントは Master  と Slave という2つの個別の役割（role）を識別しなければならないことを意味します。 Slave は、statelessリソースエージェントでの Started 状態と機能的には同じです。したがって、通常（stateless）のリソースエージェントは、 start および stop のみを実装しなければなりませんが、statefulリソースエージェントは、 Master および Started ( Slave )の役割（role）の間での遷移を可能にするため、 demote アクションもサポートしなければなりません。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_demote()</font></b> {
    <b><font color="#0000FF">local</font></b> rc

    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># test the resource's current state</font></i>
    foobar_monitor
    <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$?</font>
    <b><font color="#0000FF">case</font></b> <font color="#FF0000">"$rc"</font> <b><font color="#0000FF">in</font></b><font color="#990000">)</font>
        <font color="#FF0000">"$OCF_RUNNING_MASTER"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Running as master. Normal, expected behavior.</font></i>
            ocf_log debug <font color="#FF0000">"Resource is currently running as Master"</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">"$OCF_SUCCESS"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Alread running as slave. Nothing to do.</font></i>
            ocf_log debug <font color="#FF0000">"Resource is currently running as Slave"</font>
            <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">"$OCF_NOT_RUNNING"</font><font color="#990000">)</font>
            <i><font color="#9A1900"># Currently not running. Getting a demote action</font></i>
            <i><font color="#9A1900"># in this state is unexpected. Exit with an error</font></i>
            <i><font color="#9A1900"># and let the cluster manager recover.</font></i>
            ocf_log err <font color="#FF0000">"Resource is currently not running"</font>
            <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
            <font color="#990000">;;</font>
        <font color="#990000">*)</font>
            <i><font color="#9A1900"># Failed resource. Let the cluster manager recover.</font></i>
            ocf_log err <font color="#FF0000">"Unexpected error, cannot demote"</font>
            <b><font color="#0000FF">exit</font></b> <font color="#009900">$rc</font>
            <font color="#990000">;;</font>
    <b><font color="#0000FF">esac</font></b>

    <i><font color="#9A1900"># actually demote the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    ocf_run frobnicate --unset-master-mode <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>

    <i><font color="#9A1900"># After the resource has been demoted, check whether the</font></i>
    <i><font color="#9A1900"># demotion worked. If the resource demotion is asynchronous, the</font></i>
    <i><font color="#9A1900"># agent may spin on the monitor function here -- if the resource</font></i>
    <i><font color="#9A1900"># does not assume the Slave role within the defined timeout, the</font></i>
    <i><font color="#9A1900"># cluster manager will consider the demote action failed.</font></i>
    <b><font color="#0000FF">while</font></b> <b><font color="#0000FF">true</font></b><font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        foobar_monitor
        <b><font color="#0000FF">if</font></b> <font color="#990000">[</font> <font color="#009900">$?</font> -eq <font color="#009900">$OCF_RUNNING_MASTER</font> <font color="#990000">];</font> <b><font color="#0000FF">then</font></b>
            ocf_log debug <font color="#FF0000">"Resource still awaiting promotion"</font>
            sleep <font color="#993399">1</font>
        <b><font color="#0000FF">else</font></b>
            ocf_log debug <font color="#FF0000">"Resource demoted"</font>
            <b><font color="#0000FF">break</font></b>
        <b><font color="#0000FF">fi</font></b>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

### migrate_to アクション

migrate_to アクションは、2つの目的に対応しています。

  * リソースに対してネイティブの _push_ タイプのマイグレーションを起動します。つまり、これは、リソースがその時点で実行されているノードから、特定のノード _に_ 移動するよう指示します。リソースエージェントは、 $OCF_RESKEY_CRM_meta_migrate_target 環境変数を通じて、その宛先を知っています。 
  * _freeze/thaw_ ( _suspend/resume_ としても知られている)タイプのマイグレーションでリソースをフリーズします。通常、このモードでは、リソースはその時点でのその宛先ノードについての情報を必要としていません。 

以下の例は、pushタイプのマイグレーションを示しています。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_migrate_to()</font></b> {
    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># if resource is not running, bail out early</font></i>
    <b><font color="#0000FF">if</font></b> <font color="#990000">!</font> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
        ocf_log err <font color="#FF0000">"Resource is not running"</font>
        <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
    <b><font color="#0000FF">fi</font></b>

    <i><font color="#9A1900"># actually start up the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    ocf_run frobnicate --migrate <font color="#990000">\</font>
                       --dest<font color="#990000">=</font><font color="#009900">$OCF_RESKEY_CRM_meta_migrate_target</font> <font color="#990000">\</font>
                       <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> OCF_ERR_GENERIC
    <font color="#990000">...</font>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

対称的に、freeze/thawタイプのマイグレーションは以下のようなfreezeオペレーションを実装します。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_migrate_to()</font></b> {
    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># if resource is not running, bail out early</font></i>
    <b><font color="#0000FF">if</font></b> <font color="#990000">!</font> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
        ocf_log err <font color="#FF0000">"Resource is not running"</font>
        <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
    <b><font color="#0000FF">fi</font></b>

    <i><font color="#9A1900"># actually start up the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    ocf_run frobnicate --freeze <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> OCF_ERR_GENERIC
    <font color="#990000">...</font>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

### migrate_from アクション

migrate_from アクションは以下の2つの目的の1つに対応します。

  * リソースに対してネイティブの_push_ タイプマイグレーションを完了する。つまり、マイグレーションが正しく終了したかどうかをチェックし、リソースがローカルノードで実行されているかどうかをチェックします。リソースエージェントは、 $OCF_RESKEY_CRM_meta_migrate_source 環境変数を通じて、そのマイグレーションソースを知っています。 
  * _freeze/thaw_ ( _suspend/resume_ としても知られている)タイプマイグレーションでリソースを解凍する。このモードでは、通常、リソースはその時点でのそのソースノードについての情報を必要としていません。 

以下の例は、pushタイプのマイグレーションを示しています。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_migrate_from()</font></b> {
    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># After the resource has been migrated, check whether it resumed</font></i>
    <i><font color="#9A1900"># correctly. If the resource starts asynchronously, the agent may</font></i>
    <i><font color="#9A1900"># spin on the monitor function here -- if the resource does not</font></i>
    <i><font color="#9A1900"># run within the defined timeout, the cluster manager will</font></i>
    <i><font color="#9A1900"># consider the migrate_from action failed</font></i>
    <b><font color="#0000FF">while</font></b> <font color="#990000">!</font> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        ocf_log debug <font color="#FF0000">"Resource has not yet migrated, waiting"</font>
        sleep <font color="#993399">1</font>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

対称的に、freeze/thawタイプのマイグレーションは以下のようなthawオペレーションを実装します。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_migrate_from()</font></b> {
    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># actually start up the resource here (make sure to immediately</font></i>
    <i><font color="#9A1900"># exit with an $OCF_ERR_ error code if anything goes seriously</font></i>
    <i><font color="#9A1900"># wrong)</font></i>
    ocf_run frobnicate --thaw <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> OCF_ERR_GENERIC

    <i><font color="#9A1900"># After the resource has been migrated, check whether it resumed</font></i>
    <i><font color="#9A1900"># correctly. If the resource starts asynchronously, the agent may</font></i>
    <i><font color="#9A1900"># spin on the monitor function here -- if the resource does not</font></i>
    <i><font color="#9A1900"># run within the defined timeout, the cluster manager will</font></i>
    <i><font color="#9A1900"># consider the migrate_from action failed</font></i>
    <b><font color="#0000FF">while</font></b> <font color="#990000">!</font> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        ocf_log debug <font color="#FF0000">"Resource has not yet migrated, waiting"</font>
        sleep <font color="#993399">1</font>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

### notify アクション

通知により、clone（そして、cloneの拡張であるmaster/slaveリソース）のインスタンスは、それらの状態についてお互いに通知します。通知を有効にすると、cloneインスタスのアクションで pre と post が通知されます。そして、クラスタマネージャは、 _すべての_ cloneインスタンスで notify オペレーションを起動します。 notify オペレーションに関しては、追加の環境変数が、リソースエージェント（実行中）に渡されます。

  * $OCF_RESKEY_CRM_meta_notify_type --通知タイプ ( pre または post ) 
  * $OCF_RESKEY_CRM_meta_notify_operation — 通知が説明するオペレーション（アクション） ( start , stop , promote , demote など) 
  * $OCF_RESKEY_CRM_meta_notify_start_uname — リソースが起動されているノードの名前（ start 通知のみ） 
  * $OCF_RESKEY_CRM_meta_notify_stop_uname — リソースが停止されているノードの名前( stop 通知のみ) 
  * $OCF_RESKEY_CRM_meta_notify_master_uname — リソースがその時点で _Masterモード_ にある_ノードの名前 
  * $OCF_RESKEY_CRM_meta_notify_promote_uname — リソースがその時点でMaster roleにプロモートされているノードの名前 ( promote 通知のみ) 
  * $OCF_RESKEY_CRM_meta_notify_demote_uname — ソースがその時点でSlave roleに格下げされているノードの名前 ( demote 通知のみ) 

通知は、"pull"スキームを使っているmaster/slaveリソースに特に便利です。この場合、masterはプロバイダであり、slaveはサブスクライバとなります。masterは、プロモートが発生した時にのみ明らかであり、slaveは、正しいプロバイダに彼ら自身を加入するよう設定するために "pre-promote" 通知を使うことができます。同じように、サブスクライバも、プロバイダから脱会したいかもそれません。その場合、それに対して "post-demote" 通知を使うことができます。このコンセプトについては以下の例を参照してください。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_notify()</font></b> {
    <b><font color="#0000FF">local</font></b> type_op
    <font color="#009900">type_op</font><font color="#990000">=</font><font color="#FF0000">"${OCF_RESKEY_CRM_meta_notify_type}-${OCF_RESKEY_CRM_meta_notify_operation}"</font>

    ocf_log debug <font color="#FF0000">"Received $type_op notification."</font>
    <b><font color="#0000FF">case</font></b> <font color="#FF0000">"$type_op"</font> <b><font color="#0000FF">in</font></b>
        <font color="#FF0000">'pre-promote'</font><font color="#990000">)</font>
            ocf_run frobnicate --slave-mode <font color="#990000">\</font>
                               --master<font color="#990000">=</font><font color="#009900">$OCF_RESKEY_CRM_meta_notify_promote_uname</font> <font color="#990000">\</font>
                               <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
            <font color="#990000">;;</font>
        <font color="#FF0000">'post-demote'</font><font color="#990000">)</font>
            ocf_run frobnicate --unset-slave-mode <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
            <font color="#990000">;;</font>
    <b><font color="#0000FF">esac</font></b>

    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >master/slaveリソースエージェントは、 _multi-master_ 設定をサポートできます。この場合、常に、複数のmasterが存在します。その場合、 $OCF_RESKEY_CRM_meta_notify_*_uname 変数は、それぞれhostnameのリスト（空白文字で区切られた）を持ちます（例で示されているような1つだけのホスト名でなく）。そのような状況の下で、リソースエージェントは、このリストで正しく繰り返される必要があります。
</td></tr></table>

* * *

## スクリプト変数

本項は、リソースエージェントに提供される変数（便利さをもたらす）について説明します。エージェントが実行されている間使用できる他の変数については、 環境変数と 戻り値を参照してください。

### $OCF_ROOT

OCFリソースエージェントのディレクトリ階層のルート。これは、リソースエージェントによって変更されてはいけません。これは、通常 、/usr/lib/ocf となります。

### $OCF_FUNCTIONS_DIR

リソースエージェントshell関数ライブラリ（ .ocf-shellfuncs ）が常駐しているディレクトリ。これは、通常、 $OCF_ROOT で定義されており、リソースエージェントによって変更されてはいけません。しかし、この変数は、新規または修正リソースエージェントをテストしている間、コマンドラインから上書きされる場合があります。

### $OCF_RESOURCE_INSTANCE

リソースインスタンス名。primitive (non-clone, non-stateful) リソースに関しては、これは単なるリソース名となります。clonesおよびstatefulリソースに対してはこれはprimitive名と、その後にコロンとcloneインスタンス番号（例： p_foobar:0 ）が続きます。

### $__OCF_ACTION

その時点で起動されているアクション。これは、クラスタが、リソースエージェントを起動する場合に指定する最初のコマンドライン引数です。

### $__SCRIPT_NAME

リソースエージェントの名前。これは、リソースエージェントスクリプトのベース名です（先行するディレクトリ名が削除された）。

### $HA_RSCTMP

リソースエージェントにより使用される一時ディレクトリです。システム起動シーケンス（LSB準拠Linuxディストリビューション）は、システム起動時、このディレクトリが空にされるようにします。それにより、このディレクトリは、ノードリブートの後、状態データを含まないようになります。

* * *

## 簡易関数

### ロギング： ocf_log

リソースエージェントは、ロギングに対して ocf_log 関数を使います。この簡易ロギングラッパーは以下のように起動されます。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt>ocf_log <font color="#990000"><</font>severity<font color="#990000">></font> <font color="#FF0000">"Log message</font></tt></pre>

</td></tr></table>
 

これは、以下のseverityをサポートします。

  * debug — デバッギングメッセージ用。ほとんどのロギング設定はデフォルトでこのレベルを抑制します。 
  * info — エージェントの行動または状態に関する情報メッセージ。 
  * warn — 警告用。これは、回復できないエラーを_生じない_予想外行動を反映するメッセージに対するものです。 
  * err --エラー用。原則的にこのロギングレベルは、適切なエラーコードでの exit の直前でのみ使われるべきです。 
  * crit — クリティカルエラー用。 err でのこのロギングレベルは、リソースエージェントがエラーコードで終了する以外、使われるべきではありません。これはごくまれにしか使われません。 

### バイナリ用テスト： have_binary および check_binary

リソースエージェントは、特定の実行可能ファイルの使用可能性をテストする必要があります。ここでは have_binary 簡易関数が便利です。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#0000FF">if</font></b> <font color="#990000">!</font> have_binary frobnicate<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
   ocf_log warn <font color="#FF0000">"Missing frobnicate binary, frobnication disabled!"</font>
<b><font color="#0000FF">fi</font></b></tt></pre>

</td></tr></table>
 

バイナリのないことがリソースに対して致命的エラーとなる場合 、check_binary 関数が使われるべきです。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt>check_binary frobnicate</tt></pre>

</td></tr></table>
 

check_binary を使うのは、指定されたバイナリの存在（そして実行可能性）と $OCF_ERR_INSTALLED で終了する（見つからない場合または実行されない場合）をテストする省略メソッドです。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >テスト用のバイナリがフルパスとして指定されていない場合、 have_binary および check_binary は、両方とも $PATH を使います。バイナリインストレーションパスワードは、ディストリビューションやユーザポリシーによって異なるため、フルパスはテストしないほうがいいでしょう。
</td></tr></table>

### コマンドを実行し、それらの出力を記録する： ocf_run

リソースエージェントがコマンドを実行し、その出力を記録する必要がある場合、リソースエージェントは、この例で起動されているように ocf_run 簡易関数を使う必要があります。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt>ocf_run <font color="#FF0000">"frobnicate --spam=eggs"</font> <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font></tt></pre>

</td></tr></table>
 

上記のコマンドを使い、リソースエージェントは、 frobnicate --spam=eggs を起動し、その出力と終了コードを記録します。終了コードが非ゼロ（エラーを示す）の場合、 ocf_run が err ロギングseverityでコマンド出力をログし、そして、その後リソースエージェントは終了します。リソースエージェントが正しいコマンド実行と失敗したコマンド実行の両方の結果を記録したい場合 、 ocf_run を -v フラグで使用できます。以下の例では、 ocf_run は、コマンド終了コードがゼロの場合（成功）、コマンドからの出力を info severityでログし、コマンド終了コードがゼロ以外の場合、 err で出力をログします。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt>ocf_run -v <font color="#FF0000">"frobnicate --spam=eggs"</font> <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font></tt></pre>

</td></tr></table>
 

最後に、リソースエージェントが、ゼロ以外の終了コードのコマンドの出力を、severityが _other_ thanのエラーでログしたい場合は、 -info または -warn オプションを ocf_run に付加して行うことができます。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt>ocf_run -warn <font color="#FF0000">"frobnicate --spam=eggs"</font></tt></pre>

</td></tr></table>
 

### ロック： ocf_take_lock および ocf_release_lock_on_exit

リソースに関しては、クラスタ設定において同じタイプの異なるリソースがある場合があります。それらは、並列でアクションを実行するべきではありません。同じマシンでアクションが同時実行されないようにするために、リソースエージェントは 、ocf_take_lock および ocf_release_lock_on_exit 簡易関数を使うことができます。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><font color="#009900">LOCKFILE</font><font color="#990000">=</font><font color="#009900">${HA_RSCTMP}</font>/foobar
ocf_release_lock_on_exit <font color="#009900">$LOCKFILE</font>

<b><font color="#000000">foobar_start()</font></b> {
    <font color="#990000">...</font>
    ocf_take_lock <font color="#009900">$LOCKFILE</font>
    <font color="#990000">...</font>
}</tt></pre>

</td></tr></table>
 

ocf_take_lock は、指定された $LOCKFILE を読み込もうとします。これが不可能な場合 、ocf_take_lock は、0秒から1秒の間、ランダムな時間スリープし、その後、リトライします 。ocf_release_lock_on_exit は、エージェントが終了する場合（なんらかの理由で）、lockfileをリリースします。

### 数値に対してテストする： ocf_is_decimal

特にパラメータ検証において、指定された値が数値であるかどうかをテストすると効果的です。そのため にocf_is_decimal 関数があります。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>foobar_validate_all() {
    if ! ocf_is_decimal $OCF_RESKEY_eggs; then
        ocf_log err "eggs is not numeric!"
        exit $OCF_ERR_CONFIGURED
    fi
    ...
}</pre>


 
</td></tr> </table>

### ブール値に対してテストする： ocf_is_true

リソースエージェントがbooleanパラメータを定義する場合、そのパラメータに対する値は、 0/1 、 true/false あるいは on / off としてユーザにより指定されます。しかし、これは、リソースエージェントからの各種のすべての値をテストするには面倒であることから、エージェントは代わり にocf_is_true 簡易関数を使うべきです。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#0000FF">if</font></b> ocf_is_true <font color="#009900">$OCF_RESKEY_superfrobnicate</font><font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
    ocf_run <font color="#FF0000">"frobnicate --super"</font>
<b><font color="#0000FF">fi</font></b></tt></pre>

</td></tr></table>
 <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >ocf_is_true が、空の変数あるいは存在しない変数に対して使われると、その関数は、常に、 1 の終了コードを返します。これは false と同じです。
</td></tr></table>

### 疑似リソース： ha_pseudo_resource

「疑似リソース」というのは、リソースエージェントが、実際には、startしたりstopしたりしない実行可能プロセスに類似したもので、単一のアクションを実行するだけのものであり、したがって、アクションが実行されたかどうかを追跡する何らかのフォームが必要となります。 portblock リソースエージェントがこの例です。疑似リソースに対するリソースエージェントは ha_pseudo_resource 簡易関数を使います。この簡易関数はリソースの状態を記録する _tracking files_ を使います。 foobar が疑似リソースを管理するよう構築されている場合、その start アクションは以下のようになります。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_start()</font></b> {
    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    <i><font color="#9A1900"># if resource is already running, bail out early</font></i>
    <b><font color="#0000FF">if</font></b> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
        ocf_log info <font color="#FF0000">"Resource is already running"</font>
        <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
    <b><font color="#0000FF">fi</font></b>

    <i><font color="#9A1900"># start the pseudo resource</font></i>
    ha_pseudo_resource <font color="#009900">${OCF_RESOURCE_INSTANCE}</font> start

    <i><font color="#9A1900"># After the resource has been started, check whether it started up</font></i>
    <i><font color="#9A1900"># correctly. If the resource starts asynchronously, the agent may</font></i>
    <i><font color="#9A1900"># spin on the monitor function here -- if the resource does not</font></i>
    <i><font color="#9A1900"># start up within the defined timeout, the cluster manager will</font></i>
    <i><font color="#9A1900"># consider the start action failed</font></i>
    <b><font color="#0000FF">while</font></b> <font color="#990000">!</font> foobar_monitor<font color="#990000">;</font> <b><font color="#0000FF">do</font></b>
        ocf_log debug <font color="#FF0000">"Resource has not started yet, waiting"</font>
        sleep <font color="#993399">1</font>
    <b><font color="#0000FF">done</font></b>

    <i><font color="#9A1900"># only return $OCF_SUCCESS if _everything_ succeeded as expected</font></i>
    <b><font color="#0000FF">return</font></b> <font color="#009900">$OCF_SUCCESS</font>
}</tt></pre>

</td></tr></table>
 

* * *

## 特記事項

### ライセンス

リソースエージェント寄稿者は、新規リソースエージェントには、GNU General Public License (GPL)（バージョン2以降）を使用してください。shell関数ライブラリは、これについては強制はしていませんが、GNU General Public License (GPL)（バージョン2以降）でライセンスされています（それによりnon-GPLエージェントにより使用されます）。リソースエージェントは、自分自身のライセンスをエージェントソースコードで明示的に_記述しなければなりません_。

### ロケール設定

初期化で説明されているよう に.ocf-shellfuncs を読み込む場合、リソースエージェントの、LANG および LC_ALL は自動的に C ロケールに設定されます。それにより、リソースエージェントは、常に、 C ロケールで機能すると期待でき 、LANG やいずれの LC_ 環境変数自体をリセットする必要がありません。

### 実行中プロセスに対してテストする

特定のプロセス（既知のプロセスIDを持った）がその時点で実行されているかどうかをテストするのによく用いられる方法は、それに 0 シグナルを送り、エラーをキャッチすることです。以下に類似した方法が示されています。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#0000FF">if</font></b> kill -s <font color="#993399">0</font> `cat <font color="#009900">$daemon_pid_file</font>`<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
    ocf_log debug <font color="#FF0000">"Process is currently running"</font>
<b><font color="#0000FF">else</font></b>
    ocf_log warn <font color="#FF0000">"Process is dead, removing pid file"</font>
    rm -f <font color="#009900">$daemon_pid_file</font>
<b><font color="#0000FF">if</font></b></tt></pre>

</td></tr></table>
 

この方法は大きな欠点があります。 kill -s 0 は、zombieプロセスに対しても正しく終了します。Zombieは、defunctプロセスとしても知られているもので、実行はされてはいませんが、プロセステーブルでエントリを保持しているプロセスです。したがって、それらは、すべての場合に対して、故障したリソースと見なされ、それらに対する kill -s 0 アプローチは、誤解を招きやすい成功結果を生じます。この場合、 kill -s 0 アプローチは、別のセーフガード（ただしLinuxでしか機能しません）を使うことができます。

<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><font color="#009900">pid</font><font color="#990000">=</font>`cat <font color="#009900">$daemon_pid_file</font>`
<b><font color="#0000FF">if</font></b> kill -s <font color="#993399">0</font> <font color="#009900">$pid</font><font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
    <i><font color="#9A1900"># Process exists in process table, check its status</font></i>
    <b><font color="#0000FF">if</font></b> grep -E <font color="#FF0000">"State:[[:space:]]+Z </font><font color="#CC33CC">\(</font><font color="#FF0000">zombie</font><font color="#CC33CC">\)</font><font color="#FF0000">"</font> /proc<font color="#990000">/</font><font color="#009900">$pid</font>/status<font color="#990000">;</font> <b><font color="#0000FF">then</font></b>
    ocf_log err <font color="#FF0000">"Process is defunct"</font>
        <i><font color="#9A1900"># Bail out and let the cluster manager recover</font></i>
        <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
    <b><font color="#0000FF">else</font></b>
        ocf_log_debug <font color="#FF0000">"Process is currently running"</font>
    <b><font color="#0000FF">fi</font></b>
<b><font color="#0000FF">else</font></b>
    ocf_log warn <font color="#FF0000">"Process is dead, removing pid file"</font>
    rm -f <font color="#009900">$daemon_pid_file</font>
<b><font color="#0000FF">if</font></b></tt></pre>

</td></tr></table>
 <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Important_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >これらの例よりずっと高度はアプローチがあります。それは、daemonをクライアントプロセスに接続することにより、そのdaemonの _機能_ をテストすることです。これは、monitorアクションの例で示されています。
</td></tr></table>

### masterプリファレンスを指定する

Stateful (master/slave)リソースはそれら自身の _master プリファレンス_ を設定する必要があります。それにより、それらはクラスタマネージャにヒントを提供できます。これは、 Master roleへプロモートするためのベストインスタンスとなります。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Important_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >複数のインスタンスが同一の正のmasterプリファレンスを持つことができます。この場合、クラスタリソースマネージャは、プロモートするリソースエージェントを自動的に選択します。しかし、 _すべての_ インスタンスが（デフォルト）masterスコア（0）を持っている場合、クラスタマネージャは、どのインスタンスをもプロモートしません。 したがって、少なくとも1つのインスタンスが正のmasterスコアを持っていなければなりません。
</td></tr></table>

これに対しては、 crm_master が効果的です。 crm_attribute の簡易ラッパーは、master-$OCF_RESOURCE_INSTANCEと名前が付けられたノード属性を設定し（それが実行されているノードに対して）、指定された値をこの属性に設定します。そして、クラスタマネージャは、対応するインスタンスに対して、これをプロモートスコアに変換します。

Statefulリソースエージェントは、通常、 monitorやnotifyアクション中に crm_master を実行します。以下の例では、 foobar リソースエージェントは、アプリケーションの状態をテストすることができます。これは、以下のいずれかに基づいた特定の終了コードを返すバイナリを実行することにより行われます。

  * リソースがmaster roleかslave（masterに完全に追いついた；いずれにしても最新データを持っている）であるかどうか 
  * リソースがslave role（しかし、なんらかの非同期複製がmasterより「遅れている」）であるかどうか 
  * リソースが正しく停止されているかどうか 
  * リソースが予期しないで故障したかどうか 
<table border="0" bgcolor="#e8e8e8" width="100%" cellpadding="10" ><tr >
<td ><pre><tt><b><font color="#000000">foobar_monitor()</font></b> {
    <b><font color="#0000FF">local</font></b> rc

    <i><font color="#9A1900"># exit immediately if configuration is not valid</font></i>
    foobar_validate_all <font color="#990000">||</font> <b><font color="#0000FF">exit</font></b> <font color="#009900">$?</font>

    ocf_run frobnicate --test

    <i><font color="#9A1900"># This example assumes the following exit code convention</font></i>
    <i><font color="#9A1900"># for frobnicate:</font></i>
    <i><font color="#9A1900"># 0: running, and fully caught up with master</font></i>
    <i><font color="#9A1900"># 1: gracefully stopped</font></i>
    <i><font color="#9A1900"># 2: running, but lagging behind master</font></i>
    <i><font color="#9A1900"># any other: error</font></i>
    <b><font color="#0000FF">case</font></b> <font color="#FF0000">"$?"</font> <b><font color="#0000FF">in</font></b>
        <font color="#993399">0</font><font color="#990000">)</font>
            <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$OCF_SUCCESS</font>
            ocf_log debug <font color="#FF0000">"Resource is running"</font>
            <i><font color="#9A1900"># Set a high master preference. The current master</font></i>
            <i><font color="#9A1900"># will always get this, plus 1. Any current slaves</font></i>
            <i><font color="#9A1900"># will get a high preference so that if the master</font></i>
            <i><font color="#9A1900"># fails, they are next in line to take over.</font></i>
            crm_master -l reboot -v <font color="#993399">100</font>
            <font color="#990000">;;</font>
        <font color="#993399">1</font><font color="#990000">)</font>
            <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$OCF_NOT_RUNNING</font>
            ocf_log debug <font color="#FF0000">"Resource is not running"</font>
            <i><font color="#9A1900"># Remove the master preference for this node</font></i>
            crm_master -l reboot -D
            <font color="#990000">;;</font>
        <font color="#993399">2</font><font color="#990000">)</font>
            <font color="#009900">rc</font><font color="#990000">=</font><font color="#009900">$OCF_SUCCESS</font>
            ocf_log debug <font color="#FF0000">"Resource is lagging behind master"</font>
            <i><font color="#9A1900"># Set a low master preference: if the master fails</font></i>
            <i><font color="#9A1900"># right now, and there is another slave that does</font></i>
            <i><font color="#9A1900"># not lag behind the master, its higher master</font></i>
            <i><font color="#9A1900"># preference will win and that slave will become</font></i>
            <i><font color="#9A1900"># the new master</font></i>
            crm_master -l reboot -v <font color="#993399">5</font>
            <font color="#990000">;;</font>
        <font color="#990000">*)</font>
            ocf_log err <font color="#FF0000">"Resource has failed"</font>
            <b><font color="#0000FF">exit</font></b> <font color="#009900">$OCF_ERR_GENERIC</font>
    <b><font color="#0000FF">esac</font></b>

    <b><font color="#0000FF">return</font></b> <font color="#009900">$rc</font>
}</tt></pre>

</td></tr></table>
 

* * *

## リソースエージェントをテスト、インストール、そして、パッケージングする

本項は、リソースエージェントがいったん設定された後、何をするかについて説明します。つまり、本項ではリソースをどのようにテストするか、どこにインストールするか、そして、どのようにしてアプリケーションパッケージやLinux-HAリソースエージェントリポジトリのいずれかにインクルードするかが説明されています。

### リソースエージェントをテストする

リソースエージェントリポジトリ（したがって、インストールされたいずれのリソースエージェントパッケージ）は、 ocf-tester と名付けられたユーティリティを含んでいます。このshellスクリプトは、リソースエージェントの機能を効率的に簡単にテストできるようにします。通常、 ocf-tester は、以下で示されているように root として起動されます。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>ocf-tester -n <name> [-o <param>=<value> ... ] <resource agent></pre>


 
</td></tr> </table>

  * <name> は、任意のリソース名です。 
  * <param>=<value> は、 -o オプションで、テスト用に設定したいリソースパラメータに応じていくつでも設定できます。 
  * <resource agent> がリソースエージェントへの完全パスです。 

ocf-tester は、起動されると、すべての必須アクションを実行し、リソースエージェントアクションで説明されているようにアクションを強制実行します。

また、これは、オプショナルのアクションもテストします。オプショナルアクションは、宣伝された時、期待通りに実行される必要がありますが、実装されていない場合には、 ocf-tester がエラーを示さないようにします。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Important_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >ocf-tester はアクションの「ドライラン」を起動しませんし、いかなる種類のリソースダミーをも作成しません。そのかわり、これは、実際のリソースエージェントをそのまま実行します。この場合、それが、データベースのオープンやクローズ、ファイルシステムの実装、仮想マシンの起動や停止などを含んでいても、そのまま実行します。この場合、これは注意して使用しなければなりません。たとえば、以下のように、 foobar リソースデータベースで ocf-tester を実行することができます。
</td></tr></table> <table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre># ocf-tester -n foobartest \
             -o superfrobnicate=true \
             -o datadir=/tmp \
             /home/johndoe/ra-dev/foobar
Beginning tests for /home/johndoe/ra-dev/foobar...
* Your agent does not support the notify action (optional)
* Your agent does not support the reload action (optional)
/home/johndoe/ra-dev/foobar passed all tests</pre>


 
</td></tr> </table>

### リソースエージェントをインストールする

リソースエージェントを自分自身のプロジェクトに含めたい場合、正しい場所にそれをインストールしてください。リソースエージェントは、 /usr/lib/ocf/resource.d/<provider> ディレクトリにインストールにインストールしてください。この場合、 <provider> はプロジェクトの名前、または、リソースエージェントを識別したいなんらかの名前を入れてください。

たとえば、 foobar リソースエージェントが、 fortytwo という名前のプロジェクトの一部としてパッケージされている場合、そのリソースエージェントへの正しい完全パスは /usr/lib/ocf/resource.d/fortytwo/foobar となります。この場合、リソースエージェントは、 0755 ( -rwxr-xr-x )アクセス権限ビットでインストールしてください。

この方法でインストールを行うと、 OCF準拠クラスタリソースマネージャは、リソースエージェントを正しく識別し、パースし、実行できるようになります。たとえば、Pacemakerクラスタマネージャは、上記のインストレーションパスを ocf:fortytwo:foobar リソースタイプ識別子にマッピングします。

### リソースエージェントをパッケージする

パッケージリソースがプロジェクトの一部としてパッケージする場合、本項で説明されている注意事項に従ってください。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >代わりにリソースエージェントを Linux-HAリソースエージェントリポジトリに提出したい場合、その詳細については リソースエージェントを提出するを参照してください。
</td></tr></table>

#### RPMパッケージング

OCFリソースエージェントは 、<toppackage>-resource-agents という名前でRPMサブパッケージに入れてください。この場合、パッケージがそのプロバイダディレクトリを所有しており、上位 resource-agents パッケージ（ディレクトリ階層を設定し簡易shell関数を提供する）に依存していることを確認してください。以下にRPM仕様スニペットが示されています。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>%package resource-agents
Summary: OCF resource agent for Foobar
Group: System Environment/Base
Requires: %{name} = %{version}-%{release}, resource-agents

%description resource-agents
This package contains the OCF-compliant resource agents for Foobar.

%files resource-agents
%defattr(755,root,root,-)
%dir %{_prefix}/lib/ocf/resource.d/fortytwo
%{_prefix}/lib/ocf/resource.d/fortytwo/foobar</pre>


 
</td></tr> </table> <table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >RPM spec ファイルに %package 宣言が記述されている場合、RPMは、それ をName , Version , License などのトップレベルフィールドを継承するサブパッケージであると認識します。そのようなサブパッケージは、それ自身の名前の前に、トップレベルパッケージの名前を自動的に付加します。したがって、上記のスニペットは foobar-resource-agents (パッケージ Name は foobar であると前提されている)と名前が付けられたサブパッケージを作成します。
</td></tr></table>

#### Debianパッケージング

Debianパッケージに関しては、RPMsと同じように、リソースエージェントを保持する別のパッケージを作成してください。この場合、これは cluster-agents パッケージに依存します。

<table frame="void" style="margin:0.2em 0;" > <tr valign="top" >
<td style="padding:0.5em;" >

**_Note_**

</td>
<td style="border-left:3px solid #e8e8e8; padding:0.5em;" >本項では debhelper でパッケージングされていると前提します。以下に debian/control スニペットの例が示されています。
</td></tr></table> <table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>Package: foobar-cluster-agents
Priority: extra
Architecture: all
Depends: cluster-agents
Description: OCF-compliant resource agents for Foobar</pre>


 
</td></tr> </table>

ここでは、別の .install ファイルも作成します。 foobar リソースエージェントを fortytwo のサブパッケージとしてインストールする例に従い 、debian/fortytwo-cluster-agents.install ファイルは、以下の内容から構成されます。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>usr/lib/ocf/resource.d/fortytwo/foobar</pre>


 
</td></tr> </table>

### リソースエージェントを提出する

リソースエージェントをパッケージにバンドルしないけれども、それを、上位リソースエージェントリポジトリ（[the Linux-HA Mercurial server](http://hg.linux-ha.org/agents)でホスティングされている）に提出したい場合、本項で説明されている手順に従ってください。

まず、以下のコマンドで、上位リポジトリのワーキングコピー（Mercurial _clone_） を作成してください。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>hg clone http://hg.linux-ha.org/agents resource-agents</pre>


 
</td></tr> </table>

新規Mercurialキューと、新規パッチセットを作成してください。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>cd resource-agents
hg qinit
hg qnew --edit foobar-ra</pre>


 
</td></tr> </table>

パッチメッセージで、以下のような分かりやすい説明を記述してください。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>High: foobar: new resource agent

This new resource agent adds functionality to manage a foobar service.
It supports being configured as a primitive or as a master/slave set,
and also optionally supports superfrobnication.</pre>


 
</td></tr> </table>

リソースエージェントを heartbeat サブディレクトリにコピーしてください。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>cd heartbeat
cp /path/to/your/local/copy/of/foobar .
chmod 0755 foobar
hg add foobar
cd ..</pre>


 
</td></tr> </table>

次に、 resource-agents/heartbeat で Makefile.am ファイルを編集し、新規リソースエージェントを ocf_SCRIPTS リストに追加してください。これにより、エージェントが正しくインストールされるようにします。最後に resource-agents/doc でMakefile.amを開き 、ocf_heartbeat_<name>.7 を man_MANS 変数に追加してください。これにより、リソースエージェントのマニュアルページが、そのメタデータから自動的に作成され、そのマニュアルページが正しい場所にインストールされます。

この作業が行われたら、パッチセットを更新することができます。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>hg qrefresh</pre>


 
</td></tr> </table>

これで、パッチセットはメーリングリストで参照が可能となります。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>hg email --to=linux-ha-dev@lists.linux-ha.org foobar-ra</pre>


 
</td></tr> </table>

新規リソースエージェントが、マージできるようになれば、上位開発者は、パッチを上位リポジトリにpushします。この時点で、上位からチェックアウトを更新し、元のパッチセットを削除できます。

<table border="0" bgcolor="#e8e8e8" width="100%" style="margin:0.2em 0;" > <tr >
<td style="padding:0.5em;" ><pre>hg qpop -a
hg pull --update
hg qdelete foobar-ra</pre>


 
</td></tr> </table>
