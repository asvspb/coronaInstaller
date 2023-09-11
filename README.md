# coronaInstaller

# Краткое напоминание о процессе установки

 - на винде:
	- создать вируталку: 30gb + 3gb ram + bridged adaptor
	- удалить в папке .ssh отпечатки предыдущих конектов в файле known_hosts
	- добавить в c:\windows\system32\drivers\etc\hosts
	'192.168.1.160 ccq.l.cidious.com grafana-ccq.l.cidious.com redis-ccq.l.cidious.com monitor.l.cidious.com dash-ccq.l.cidious.com pgadmin-ccq.l.cidious.com umami-ccq.l.cidious.com'
	- включить поддержку samba (control panel / turn windows features on/off)
	- включить map network drive на сетевом диске (правый клик)
 - на сервере:
	- добавить пароль в первый скрипт
	- установить докер
 - на винде:
	- законектиться по ssh и установить корону
	- отключить все виды vpn 
 
 