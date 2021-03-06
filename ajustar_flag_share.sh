#!/bin/bash
#Fabio S. Schmidt - fabio@bktech.com.br
#v1.0
# *** SCRIPT VALIDO SOMENTE PARA AMBIENTES COM O ZIMLET SHARE TOOLKIT INSTALADO! ***
#Script para remover a flag "i" caso encontre em alguma pasta
#Esse script ira recriar os compartilhamentos novamente
#pastas com flag i podem nao ser exibidas pelos clientes de e-mail
#
#Fonte: https://wiki.zimbra.com/wiki/Clearing_the_%22don%27t_inherit_grants_from_parent_folder%22(i)_flag
#
# - Script modificado para tratar acentuacao do portugues e traduzido

#Tratar acentuacao do portugues
export LC_ALL="pt_BR.UTF-8"
account=$1
subzim="/usr/local/sbin/subzim"

if [ x"$(id -n -u)" != x"zimbra" ]
then
        echo "Esse script deve ser executado com o usuario Zimbra"
        exit 1
fi

zmprov ga "$1" &> /dev/null

if [ $? -ne 0 ]
then
        echo "A conta informada nao existe"
        exit 1
fi

echo "Atencao: Esse script e valido somente para ambientes com o share toolkit instalado"

echo "Consultando os compartilhamentos existentes"
shares=`zmmailbox -z -m $1 gfg / | awk '{print $3}' | grep -v -e '^Display' -e '-'`
echo "Compartilhamentos existentes: $shares"

zmmailbox -z -m "$account" gaf | sed "1,2d" | cut -d "/" -f "2-" | while read folder
do
        echo "Analisando a pasta '/$folder'"
        oldflags=$(zmmailbox -z -m "$account" gf "/$folder" | grep flags | head -n 1 | cut -d ":" -f 2 | sed 's@[^"]*"\([^"]*\)".*@\1@')
        echo " ** flags existentes : '$oldflags'"
        newflags=$(echo "$oldflags" | sed 's@i@@g')
        echo " ** novas flags : '$newflags'"

        if [ x"$oldflags" != x"$newflags" ]
        then
                echo "=> Aplicando as novas flags - somente remove a flag i"
                zmmailbox -z -m "$account" mff "/$folder" "$newflags"
                if [ $? -eq 0 ]
                then
                        echo "** Novas flags aplicadas com sucesso"
                else
                        echo "** Falha ao aplicar as flags"
                fi
        else
                echo "=> Nenhuma alteracao necessaria"
        fi
        echo "<-------------------------------------------->"
done;

echo "Aplicando novamente os compartilhamentos"
      for SHARE in `echo $shares`
do
      $subzim $shares $1 2>/dev/null
done
