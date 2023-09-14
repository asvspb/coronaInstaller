# coronaWinstaller

# Краткое напоминание о процессе установки

 - на винде:
	- создать вируталку: 30gb + 3gb ram + bridged adaptor
	- если есть, удалить в папке .ssh отпечатки предыдущих конектов в файле known_hosts
 - на сервере:
	- добавить пароль в первый скрипт
		unzip -P тУтПаРоЛь -d "$HOME" archive.zip
	- установить докер
 - на винде:
	- добавить в c:\windows\system32\drivers\etc\hosts
		'192.168.1.160 ccq.l.cidious.com grafana-ccq.l.cidious.com redis-ccq.l.cidious.com monitor.l.cidious.com dash-ccq.l.cidious.com pgadmin-ccq.l.cidious.com umami-ccq.l.cidious.com'
	- включить поддержку samba (control panel / turn windows features on/off)
	- включить map network drive на сетевом диске (правый клик)
	- законектиться по ssh и установить корону
	- запуск проекта чувствителен ко всем vpn 
 
 
