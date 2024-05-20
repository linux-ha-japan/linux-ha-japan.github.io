---
attachment_url: /wp/wp-content/uploads/02resource_monitor_error.swf
author: kmii
comments: false
date: 2011-05-09 12:14:47+00:00
excerpt: PostgreSQLでプロセス故障が発生したときの動作
layout: post
permalink: /wp/archives/1465/02resource_monitor_error
slug: 02resource_monitor_error
title: 02resource_monitor_error
wordpress_id: 1471
---

### [02resource_monitor_error]({{ site.lhajp_resources_url }}/wp-content/02resource_monitor_error.swf)

リソース故障(PostgreSQL)を発生させます。
Pacemakerが故障を検知し、リソースをフェイルオーバさせます。
故障復旧後、次のコマンドで故障状態をクリアします。

# crm resource cleanup prmPg
