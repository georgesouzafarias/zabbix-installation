	#!/bin/bash
	#!/usr/bin/env bash
	


	variaveis()
	{
	DATA=`date +%x-%k:%M:%S` #pega data atual
	LOG_ZABBIX_INSTALACAO_ERRO=/tmp/instalacao_zabbix
	}


	cabecalho()
	{
	echo "######################################################################" > $LOG_ZABBIX_INSTALACAO_ERRO
	echo "##                                                                  ##" >> $LOG_ZABBIX_INSTALACAO_ERRO
	echo "## Configuração do Agente Zabbix para linux OS				      ##" >> $LOG_ZABBIX_INSTALACAO_ERRO
	echo "## Desenvolvedor: George Souza Farias			                      ##" >> $LOG_ZABBIX_INSTALACAO_ERRO
	echo "## Data: 22/02/2013                                                 ##" >> $LOG_ZABBIX_INSTALACAO_ERRO
	echo "##   Inicio: $DATA   SO: $DIST 		Arquitetura: $MACH            ##" >> $LOG_ZABBIX_INSTALACAO_ERRO
	echo "######################################################################" >> $LOG_ZABBIX_INSTALACAO_ERRO
	}

	qualSO ()
	{
		#Variavel armazena o SO.
		OS=`uname -s`
		
		REV=`uname -r`
		#Armazena a arquitetura do sistema operacional
		MACH=`uname -m`
		
		#Variavel que armazena a distribuicao.
		DIST="Desconhecido"
		#Variavel que armazena o Codinome da Distribuicao
		PSEUDONAME="Desconhecido"
		#variavel que armazena a versao da Distribuicao
		REV="Desconhecido"

		if [ "${OS}" = "SunOS" ] ; then
			OS=Solaris
			DIST=Solaris
			ARCH=`uname -p`	
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
			msg_erro $OSSTR
		elif [ "${OS}" = "AIX" ] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
			msg_erro $OSSTR
		elif [ "${OS}" = "Linux" ] ; then
			KERNEL=`uname -r`
			# RedHat ou Centos
			if [ -f /etc/redhat-release ] ; then
				DIST=`cat /etc/redhat-release | cut -d' ' -f1`
				PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			# Debian, Ubuntu e variantes
			elif [ -f /etc/debian_version ] ; then
				# Verifica se o LSB esta instalado
				LSB=`which lsb_release`
				# Se nao estiver, configura no braco
				if [ -z "$LSB" ] ; then
					DIST="Debian"
					REV=`cat /etc/debian_version`
				# Se nao, usa o LSB. Ubuntu eh reconhecido aqui
				else
					DIST=`lsb_release -si`
					PSEUDONAME=`lsb_release -sc`
					REV=`lsb_release -sr`
				fi
			# TODO: Validar do suse
			elif [ -f /etc/SuSE-release ] ; then
				DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			fi

			OSSTR="${OS} ${DIST} ${REV} (${PSEUDONAME} ${KERNEL} ${MACH})"
		fi
		echo $DIST >> $LOG_ZABBIX_INSTALACAO_ERRO
		echo $MACH >> $LOG_ZABBIX_INSTALACAO_ERRO
		
	}

	install_debian(){
		
		cd ~
		mkdir zabbix_instalacao
		cd zabbix_instalacao
		wget 10.50.1.16/agent/zabbix-agent-Debian -O /etc/init.d/zabbix-agent	2>> $LOG_ZABBIX_INSTALACAO_ERRO
		chmod +x /etc/init.d/zabbix-agent
		#cp zabbix-agent-Debian /etc/init.d/zabbix-agent 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		update-rc.d -f zabbix-agent defaults > /dev/null 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		aptitude install sudo -y > /dev/null 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		echo "zabbix ALL=NOPASSWD:ALL" >> /etc/sudoers 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		MACH=$(echo $MACH |tr [:lower:] [:upper:])
		#if [ "$MACH" == "I386" ] ; then
		#	 echo 32bit
			wget 10.50.1.16/agent/zabbix.32bit.tar.gz >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
			tar -xvf zabbix.32bit.tar.gz >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		#else
		#	tar -xvf zabbix_2.0.3.64bit.tar.gz
			 
		# fi
			
		}

	install_redhat(){
		wget 10.50.1.16/agent/zabbix-agent-RedHat -O /etc/init.d/zabbix-agent >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		#cp zabbix_agent-RedHat /etc/init.d/zabbix-agent 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		chmod +x /etc/init.d/zabbix-agent
		chkconfig zabbix-agent on 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		echo "zabbix ALL=NOPASSWD:ALL" >> /etc/sudoers 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		 
		MACH=$(echo $MACH |tr [:lower:] [:upper:])
		#if [ "$MACH" == "I386" ] ; then
			wget 10.50.1.16/agent/zabbix.32bit.tar.gz >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
			tar -xvf zabbix.32bit.tar.gz >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		#else
			#tar -xvf zabbix_2.0.3.64bit.tar.gz
		 
		 #fi
		
	}

	install_solaris(){
		
		
		
		read -p "Qual a Versao do SOlaris ? 10 ou 11  " SOLARIS_VERSAO
		
		cp zabbix-agent-Solaris /etc/init.d/zabbix-agent 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		chown root:sys /etc/init.d/zabbix_agentd 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		chmod 744 /etc/init.d/zabbix_agentd 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		cp /etc/init.d/zabbix_agentd /etc/rc3.d/S99zabbix_agentd 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		chown root:sys /etc/rc3.d/S99zabbix_agentd 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		echo "zabbix ALL=NOPASSWD:ALL" >> /etc/sudoers 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		if [ "$DIST" == "SOLARIS" ] ; then
			if [ "$SOLARIS_VERSAO" == "10" ] ; then
			 tar -xvf zabbix_agents_2.0.3.solaris10.64bit.tar.gz
		
			else
			
			 tar -xvf zabbix_agents_2.0.3.solaris11.64bit.tar.gz
			 
		   fi
	 fi
		
	   
		
	}

	iniciando_instalacao(){
		
	wget 10.50.1.16/agent/zabbix/zabbix_agentd.conf -P /usr/local/etc/	>> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
	#cp -rf zabbix/* /usr/local/etc/ >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
	useradd zabbix 2>> $LOG_ZABBIX_INSTALACAO_ERRO
	groupadd zabbix 2>> $LOG_ZABBIX_INSTALACAO_ERRO
	 
	}


	finalizando_instalacao(){

		/etc/init.d/zabbix-agent stop >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO

		cp -fr bin/* /usr/local/bin/ >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		cp -fr sbin/* /usr/local/sbin/ >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		mkdir /var/log/zabbix 2>> $LOG_ZABBIX_INSTALACAO_ERRO

		mkdir /var/run/zabbix 2>> $LOG_ZABBIX_INSTALACAO_ERRO

		chown zabbix.zabbix /var/log/zabbix /var/run/zabbix 2>> $LOG_ZABBIX_INSTALACAO_ERRO

		/etc/init.d/zabbix-agent start >> $LOG_ZABBIX_INSTALACAO_ERRO 2>> $LOG_ZABBIX_INSTALACAO_ERRO
		
		cd ~
		
		rm -rf zabbix_instalacao

	}

	variaveis

	qualSO
		 
	cabecalho


	iniciando_instalacao

	 
	 
	DIST=$(echo $DIST|tr [:lower:] [:upper:])

	case $DIST in 

	  DEBIAN)
		   install_debian
	  ;; 
	 UBUNTU)
		   install_debian
	  ;; 
	  RED)
		   install_redhat
	  ;; 
	  FEDORA)
		   install_redhat
	  ;; 
	  SOLARIS)
		   install_solaris
		
	  ;;
	  CENTOS)
		   install_redhat
		
	  ;;
		
	  *)
		 echo "A Distribuicao $DIST nao é compativel";
		 
	  ;;
	  
	esac


	finalizando_instalacao