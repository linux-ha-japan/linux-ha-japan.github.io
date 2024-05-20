---
author: bellche
comments: false
date: 2011-10-03 07:34:30+00:00
layout: post
permalink: /wp/archives/2363
slug: lcmc%ef%bc%88linux-cluster-management-console%ef%bc%89%e3%81%8c%e5%87%ba%e3%81%be%e3%81%97%e3%81%9f%e3%80%82
title: LCMC（Linux Cluster Management Console）が出ました。
wordpress_id: 2363
categories:
- ニュース
- リリース情報
---

DRBD-MCとしてリリースされていたLinux-HAのGUI環境ですが、この度、DRBD-MCからフォークしてLCMC（Linux Cluster Management Console）としてバージョン１．０．０リリースされました。

 


<blockquote>Good news everyone!

I am happy to announce LCMC, Linux Cluster Management Console. LCMC is a
Java GUI application that configures, manages and visualizes Linux clusters in a
way that is not possible to be web-based. Specifically it manages clusters
that use one or more of these components: Pacemaker, Corosync, Heartbeat,
DRBD, KVM, XEN and LVM.

If that sounds familiar, you are right, LCMC is a fork of DRBD MC, that
unexpectedly passed away. Yes, I was surprised as you are, but after couple of
minutes of mourning the untimely death as the developer of the DRBD MC, I
decided to continue with it. I think I am not the only one to mourn it, other
Pacemaker GUIs have a long long way to go and also this one is awesome.

From the user point of view, LCMC is just a long needed name and design
change, reflecting that the scope of the GUI is bigger than the DRBD, but
DRBD as a small clever software that replicates disks, is still the central
part of the GUI.

Unfortunately as of now I am also not paid, not even badly to work on it,
so don't expect me to add many new features for some time, but I am
still maintaining it, waiting for support or suggestions to keep it running,
the LCMC being in the low gear with my foot on the throttle, waiting to push
it if needed.

Please check out the web site:
http://lcmc.sf.net

Screenshot:
http://sourceforge.net/dbimage.php?id=316273

Source code:
https://github.com/rasto/lcmc

Rasto Levrinc
_______________________________________________
Linux-HA mailing list
Linux-HA [at] lists
http://lists.linux-ha.org/mailman/listinfo/linux-ha
See also: http://linux-ha.org/ReportingProblems</blockquote>



Rasto氏はLINBIT退社したそうです…。
