#TYPO3 CMS 6.2 Vagrant on CentOs

A Vagrant Box installing TYPO3 CMS 6.2 on Top of CentOs with PHP 5.5
It is loosly based on https://github.com/paschdan/vagrant-typo3

## Requirements

1. Oracle VirtualBox
2. Vagrant 1.7.0+

## Setup
1. Clone this repository recursive:
    `git clone --recursive https://github.com/peschmae/vagrant-typo3.git`

2. Edit your hosts-file and add 192.168.33.62 as typo3.local:
    `echo 192.168.33.62 typo3.local | sudo tee -a /etc/hosts`

3. `vagrant up`

4. Add a file `FIRST_INSTALL` to the `www/typo3.local`:
    `touch www/typo3.local/FIRST_INSTALL`

5. Go to [http://typo3.local](http://typo3.local)

6. Follow the Installation-Tool instructions. Database-User is "root" with password 'toor'.

7. You are Ready with a fresh install of TYPO3 CMS.

## ToDo
Synced folders currently dont work
I tried with bindfs, but that only works for debian not for centos (or at least not by default)

## Contributing

Currently this vagrant box, is intended for my privat use, while developing extensions.
Since the purpose is just for myself, I wont accept any contributions except bugfixes. (Or updates to modules)

If you like the box, and want to extend it, feel free to fork this repository and start working on your own box.