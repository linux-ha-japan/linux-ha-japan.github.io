---
author: t-matsuo
comments: false
date: 2010-06-22 11:30:45+00:00
layout: page
permalink: /wp/manual/pminstall_cent5
published: false
slug: pminstall_cent5
title: Pacemakerインストール方法 CentOS 5編
wordpress_id: 56
---



CentOS5.5 x86_64 にPacemakerをインストールする方法は、主に以下の4つがあります。

ここでは、下記の1, 2 の方法について記述します。



	
  1. yum を使ってネットワークインストール

	
    * Pacemaker本家(clusterlabs) の yumのリポジトリを使用



	
    * インターネット接続必須

	
    * 最新の安定バージョンをいち早く使ってみたい人向け (?)




	
  2. Linux-HA Japan 提供のローカルリポジトリ + yum を使ってインストール

	
    * Linux-HA Japan オリジナルパッケージも含まれる

	
    * インターネット接続は必須ではない

	
    * Linux HA Japan 推奨バイナリ (^ ^)




	
  3. rpm を手動でインストール

	
    * 上記1 ,2 で公開されているrpmを個別にダウンロードしてインストール

	
    * ちょっと手間がかかる




	
  4. ソースからインストール

	
    * かなり手間がかかるけど、バイナリが提供されていないLinuxディストリビューションにインストールしたい場合

	
    * 開発者や開発版の最新機能をいち早く使ってみたいチャレンジャー向け (?)





  


システム構成は、下図のように、ホスト名が 「pm01」と「pm02」の2台、インターコネクトLANに、eth1とeth3を使用するとします。

※インターコネクト用ネットワークインタフェースは、可用性を高めるために物理的に異なるボードの使用を推奨


[![Pacemaer 基本構成](/assets/images/wp-content/pm_simple_env.jpg)](/wp/manual/pminstall_cent5/pm_simple_env)


さらに、Pacemakerでは、下図のように、クラスタ制御部にHeartbeat 3 またはCorosync を使用することができますので、それぞれの場合について記述します。


[![hb3_or_corosync](/assets/images/wp-content/hb3_or_corosync.jpg)](/wp/manual/pminstall_cent5/hb3_or_corosync)


なお、以下には「pm01」の1台分の構築手順しか記載していませんが、「pm01」「pm02」どちらも同じ手順でインストールしてください。

  



## yum を使ってネットワークインストール








	
  * 足りないライブラリのインストールPacemakerのインストールには、rpmパッケージ依存の関係上、libesmtpのインストールが必要です。CentOS5.5にはlibesmtpは同梱されて無いため、Fedoraプロジェクトで提供されているepelのパッケージのリポジトリも使用させて頂きます。



    
    [root@pm01 ~]# <strong>wget http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm</strong>
    [root@pm01 ~]# <strong>rpm -ivh epel-release-5-4.noarch.rpm</strong>


  




	
  * yumリポジトリを設定 clusterlabs.org からrepoファイルをダウンロードして、yumリポジトリを設定します。



    
    [root@pm01 ~]# <strong>cd /etc/yum.repo.d</strong>
    [root@pm01 ~]# <strong>wget http://clusterlabs.org/rpm/epel-5/clusterlabs.repo</strong>


  




	
  * yumでインストールyumコマンドによりインストールを実行します。



    
    [root@pm01 ~]# <strong>yum install corosync.x86_64 heartbeat.x86_64 pacemaker.x86_64</strong>



    
    rpmの依存関係で以下のパッケージも自動的にインストールされます。



    
    pacemaker-libs
    corosynclib
    cluster-glue
    cluster-glue-libs
    resource-agents
    heartbeat-libs
    libesmtp (epelからダウンロードされる)


  



## Linux-HA Japan 提供のローカルリポジトリ + yum を使ってインストール


Linux-HA Japanでは、ネットワーク接続環境がない場合にも手軽にインストールできるように、yum用のローカルリポジトリを提供しています。なお、ローカルリポジトリにはLinux-HA Japan オリジナル追加機能のパッケージも含まれます。



	
  * [Linux-HA Japan 開発サイト](http://sourceforge.jp/projects/linux-ha/releases/?package_id=11413)からローカルリポジトリのダウンロード※ここではpacemaker-1.0.9.1-1.15.1.el5.x86_64.repo.tar.gz をダウンロードしたと仮定します。

	
  * ダウンロードしたローカルリポジトリを/tmp に展開



    
    [root@pm01 ~]# mv pacemaker-1.0.9.1-1.15.1.el5.x86_64.repo.tar.gz /tmp
    [root@pm01 ~]# cd /tmp
    [root@pm01 ~]# tar zxvf pacemaker-1.0.9.1-1.15.1.el5.x86_64.repo.tar.gz





	
  * インストール依存しているOS付属のRPMは、ネットワークからダウンロードされます。ネットワーク環境がない場合は、下記の"ネットワークに繋がらない場合は”を事前に設定しておきます。



    
    [root@pm01 ~]# cd pacemaker-1.0.9.1-1.15.1.el5.x86_64.repo
    [root@pm01 ~]# yum -c pacemaker.repo install corosync.x86_64 heartbeat.x86_64 pacemaker.x86_64


 


### CentOS 6 や Scientific Linux 6 使用時の注意




CentOS 6やScientific Linux 6を使用する場合、異なるバージョンのPacemakerがOSに同梱されていますので、インストールする場合はまずはこれらを削除するか、バージョンを指定して
インストールを行ってください。 

    
    [root@pm01 ~]# yum -c pacemaker.repo install pacemaker-1.0.11・・・


また、yum update を実行するとOS同梱版にアップデートされてしまいますので、対象のリポジトリ設定ファイル (/etc/yum.repo.d/****.repo) に以下のような記述を追記しておくと便利です。

    
    exclude=pacemaker pacemaker-libs corosync cluster-glue heartbeat resource-agents



 


### ネットワークに繋がらない場合は




ネットワークに繋がらない環境では、依存しているOS付属のRPMがダウンロードできないため、エラーになります。




その場合は、インストールメディア(DVD)をセットし、以下のように設定します。






	
  * インストールメディアのマウント

	
  * 

    
    [root@pm01 ~]# mkdir /mnt/centos5
    [root@pm01 ~]# mount /dev/dvd /mnt/centos5






	
  * リポジトリの設定/etc/yum.repos.d/CentOS-Media.repo ファイルに以下のように記述。ファイルが存在しない場合は新規に作成します。

	
  * 

    
    [c5-media]
    name=CentOS5-Media
    baseurl=file:///mnt/centos5
    gpgcheck=1
    enabled=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5







Red Hat Enterprise Linux 5 の場合、baseurl=file:///mnt/centos5/Server とし、gpgcheck=0 と設定すれば、同様に設定可能です。c5-media や CentOS5-Media といった文字列は、任意の文字列に変更しても構いません。






	
  * ネットワークリポジトリを無効にしておく

	
  * 

    
    [root@pm01 ~]# mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak






	
  * 設定の確認c5-media という行が出力されることを確認

	
  * 

    
    [root@pm01 ~]# yum list  | grep c5-media
    Cluster_Administration-as-IN.noarch        5.2-1.el5.centos            c5-media
    Cluster_Administration-bn-IN.noarch        5.2-1.el5.centos            c5-media
    Cluster_Administration-de-DE.noarch        5.2-1.el5.centos            c5-media
    ～ 省略 ～





  



### Proxy環境の場合は




/etc/yum.conf でproxyを設定していても、yum -c でインストールする際このProxy設定は無視されてしまします。よって、一時的に以下のように環境変数を定義してあげてください。






	
  * 

    
    [root@pm01 ~]# export http_proxy=http://ProxyのIP:port番号







 





## クラスタ制御部にCorosyncを使用する場合の設定


※Heartbeat3を使用する場合は設定不要



	
  * /etc/corosync/corosync.conf ファイルを以下のように設定します。



    
    aisexec {
        user: root
        group: root
    }
    service {
        name: pacemaker
        ver: 0
        use_mgmtd: yes
    }
    totem {
        version: 2
        secauth: off
        threads: 0
        rrp_mode: active
        clear_node_high_bit: yes
        token: 4000
        consensus: 10000
        rrp_problem_count_timeout: 3000
        interface {                    <span style="color: #ff0000;">← 1本目のインターコネクトの設定</span>
            ringnumber: 0
            bindnetaddr: 192.168.10.0          <span style="color: #ff0000;">← インターコネクトLANのIPではなく、ネットワークアドレスを指定</span>
            mcastaddr: 226.94.1.1
            mcastport: 5405                    <span style="color: #ff0000;">← 複数のPacmakerのインターコネクトを同じLANで使用する場合は</span>
        }                                        <span style="color: #ff0000;">ポート番号を変更すること</span>
        interface {                       <span style="color: #ff0000;">← 2本目のインターコネクトの設定</span>
            ringnumber: 1
            bindnetaddr: 192.168.30.0
            mcastaddr: 226.94.1.1
            mcastport: 5405
        }
    }
    logging {
        fileline: on
        to_syslog: yes
        syslog_facility: local1
        syslog_priority: info
        debug: off
        timestamp: on
    }


  



## クラスタ制御部にHeartbeat3を使用する場合の設定


※Corosyncを使用する場合は設定不要



	
  * /etc/ha.d/ha.cf ファイルを以下のように編集します



    
    pacemaker on
    logfacility local1
    
    debug 0
    udpport 694       <span style="color: #ff0000;">← 複数のクラスタを同じインターコネクトLAN上で使用する場合は
                        ポート番号を変更すること </span>
    keepalive 2
    warntime 20
    deadtime 24
    initdead 48
    
    bcast eth1        <span style="color: #ff0000;">← 1本目のインターコネクトのインタフェース</span>
    bcast eth3        <span style="color: #ff0000;">← 2本目のインターコネクトのインタフェース</span>
    
    node pm01         <span style="color: #ff0000;">← Heartbeat3で使用する1台目のサーバの「uname -n」コマンドで表示されるホスト名</span>
    node pm02         <span style="color: #ff0000;">← Heartbeat3で使用する2台目のサーバの「uname -n」コマンドで表示されるホスト名
    <span style="color: #000000;">watchdog /dev/watchdog</span>
    </span>





	
  * 以下の内容の認証キーファイルを/etc/ha.d/authkeys に配置



    
    auth 1
    1 sha1 abcdefg   <span style="color: #ff0000;">← "abcdefg" は任意の文字列だが、全てのサーバで同じ文字列を設定すること</span>





	
  * 認証キーのパーミッション、所有ユーザ・グループを設定



    
    [root@pm01 ~]# chown root:root /etc/ha.d/authkeys
    [root@pm01 ~]# chmod 600 /etc/ha.d/authkeys


  



## ログの設定


※必須の設定ではありません。

Pacemakerは大量のログをsyslogを使用して、/var/log/messages に出力してしまうので、これを他のファイルに変更します。



	
  * /etc/syslog.conf を設定ここでは、/var/log/ha-log にログを出力するように設定します。また、同内容のログを /var/log/messages に2重出力しないように、「local1.none」の追記も行います。



    
    *.info;mail.none;authpriv.none;cron.none;<span style="color: #ff0000;">local1.none</span>	    /var/log/messages
    	  ：
    	（省略）
    	  ：
    <span style="color: #ff0000;">local1.*                                                    /var/log/ha-log</span>




## Pacemakerの起動





	
  * Pacemakerの起動 (Corosync使用時の場合)



    
    [root@pm01 ~]# <strong>service corosync start</strong>
    Starting Corosync Cluster Engine (corosync):       [  OK  ]
    
    [root@pm02 ~]# <strong>service corosync start</strong>
    Starting Corosync Cluster Engine (corosync):       [  OK  ]


  




	
  * Pacemakerの起動 (Heartbeat3使用時の場合)



    
    [root@pm01 ~]# <strong>service heartbeat start</strong>
    Starting High-Availability services:               [  OK  ]
    
    [root@pm02 ~]# <strong>service heartbeat start</strong>
    Starting High-Availability services:               [  OK  ]




  
 
	
  * 起動の確認
Pacemakerの起動の確認は、状態表示コマンドのcrm_monコマンドを使用します。設定したサーバがOnlineになることを確認します。なお、Onlineになるまで1分程度要します。以下はHeartbaet3 を使用した場合の表示例ですが、Corosyncもほぼ同等の表示です。



    
    [root@pm01 ~]# <strong>crm_mon</strong>
    ============
    Last updated: Mon Sep  6 07:07:07 2010
    Stack: Heartbeat
    Current DC: pm02 (62b25071-2d16-4e9e-a323-af21616d5269) - partition with quorum
    Version: 1.0.9-89bd754939df5150de7cd76835f98fe90851b677
    2 Nodes configured, unknown expected votes
    0 Resources configured.
    ============
    
    Online: [ <span style="color: #ff0000;">pm01 pm02</span> ]


  


以上でPacemakerのインストールは完了です。

この状態では、リソース(制御対象のアプリケーション)を定義していないため、続いて[crmコマンドを使用してリソース制御部の設定](/wp/archives/4224)を行っていきます。




[root@pm01 ~]# service corosync start

Starting High-Availability services:               [  OK  ]


