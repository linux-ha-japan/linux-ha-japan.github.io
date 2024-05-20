---
author: ikedaj
comments: false
date: 2011-04-01 08:06:07+00:00
layout: post
permalink: /wp/archives/1283
slug: stonith-plugin-eject-is-out-now
title: STONITH plugin "eject" is out now!
wordpress_id: 1283
categories:
- 読み物
tags:
- pacemaker
- April Fool
---

Split Brain is the most awful situation in the cluster world,  

 and it's recommended to prepare a hardware management board and setup the STONITH plugin.  

 But some cheep machine might not have such an expensive board...





So, good news for such users!  

 STONITH plugin "eject" is out now!





This plugin doesn't need special devices.  

 It just needs an optical drive, like CD-ROM drive.





If you setup this plugin, you can power off the machine with the optical drive like this.  

 





  






[![eject STONITH Plugin](/assets/images/wp-content/eject.jpg)](/wp/archives/1272/eject-2)





  






**NOTICE:**  

 Set up 2 PCs face-to-face.  

 Adjust the height of the both PC.  

 You may need some BIOS configurations for Power Management.  

 You can not select the STOTNIH type, for example, power on/off/reset.





  






After the success fail over,  re-set the equipment layout.





  







**HOT TO INSTALL:**  

 download "[eject](/wp/?attachment_id=1273)" .





copy it to the right place.  

 # cp eject /usr/lib/stonith/plugins/external/  

 # chmod 755 /usr/lib/stonith/plugins/external/eject   

 or  

 # cp eject /usr/lib64/stonith/plugins/external/  

 # chmod 755 /usr/lib64/stonith/plugins/external/eject





  






**REQUIRED PARAMETER:**  

 hostname
