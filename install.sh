#!/bin/bash
#===================================================================================
#
#         FILE:  install.sh
#
#        USAGE:  ./install.sh 
#
#     SYNOPSIS:  Install the Vim plugin nqc.vim from the current directory
#
#  DESCRIPTION:  Do the 5 steps described in the file README to install the plugin.
#                Step 5 starts vim to allow the personalization. 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#      COMPANY:  FH Südwestfalen, Iserlohn
#      VERSION:  1.0
#      CREATED:  27.12.2003
#     REVISION:  
#===================================================================================

usage="\n\tusage:  $0 [-p] [-t target_directory] \n" 

source_dir='.'              # the directory of this script
target='.vim'               # the local target directory (subdirectory .vim )
personalize=0               # personalization 0=no / 1=yes

while getopts "\?pt:" option
do
  case $option in
    p )   personalize=1;;
    t )   target=$OPTARG;;
    \? )  echo -e  $usage
          exit 1
  esac
done

target_dir=$HOME/$target    # the complete target directory

#-----------------------------------------------------------------------
#  (1) Create directories
#-----------------------------------------------------------------------

mkdir  -p $target_dir
mkdir  -p $target_dir/doc
mkdir  -p $target_dir/ftplugin
mkdir  -p $target_dir/plugin
mkdir  -p $target_dir/plugin/templates
#mkdir  -p $target_dir/wordlists
mkdir  -p $target_dir/codesnippets-nqc


#-----------------------------------------------------------------------
#  (2) Copy files
#-----------------------------------------------------------------------

cp $source_dir/doc/nqcsupport.txt   $target_dir/doc/

if [ -e $target_dir/ftplugin/nqc.vim ]
then
  mv $target_dir/ftplugin/nqc.vim $target_dir/ftplugin/nqc.vim.save
fi

cp  $source_dir/ftplugin/nqc.vim           $target_dir/ftplugin/
cp  $source_dir/doc/nqcsupport.txt         $target_dir/doc/
#cp  $source_dir/wordlists/*                $target_dir/wordlists/
cp  $source_dir/plugin/nqc.vim             $target_dir/plugin/
cp  $source_dir/plugin/templates/*         $target_dir/plugin/templates/


#-----------------------------------------------------------------------
#  (3) Generate the local help tags file.
#-----------------------------------------------------------------------

vim -es -c "helptags $HOME/.vim/doc"  -c "q"


if [ $personalize -eq 1 ]
then
  #-----------------------------------------------------------------------
  #  (4) Append the file  nqc.vimrc  to  .vimrc
  #-----------------------------------------------------------------------

  cat $source_dir/rc/nqc.vimrc  >> $HOME/.vimrc

  #-----------------------------------------------------------------------
  #  (5) Go into insert mode; allow personalization.
  #-----------------------------------------------------------------------

  vim $HOME/.vimrc -c $                       \
                   -c '?g:NQC_AuthorName'     \
                   -c 'normal 2f"'            \
                   -c startinsert

fi
