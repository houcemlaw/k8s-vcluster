# Vagrant Command Cheat Sheet

## Starting a VM

-- starts vagrant environment (also provisions only on the FIRST vagrant up)
`vagrant up` 

-- resume a suspended machine (vagrant up works just fine for this as well)
`vagrant resume`  

-- forces reprovisioning of the vagrant machine
`vagrant provision`

-- restarts vagrant machine, loads new Vagrantfile configuration
`vagrant reload`

-- restart the virtual machine and force provisioning
`vagrant reload --provision`


## SSH into a specific node/box (ex. node01)
`vagrant ssh node01`	

## Stopping a VM
-- stops the vagrant machine
`vagrant halt`

-- suspends a virtual machine (remembers state)
`vagrant suspend `

## Cleaning Up a VM

-- stops and deletes all traces of the vagrant machine
`vagrant destroy `

-- same as above, without confirmation
`vagrant destroy -f`

## Boxes
-- see a list of all installed boxes on your computer
`vagrant box list `

-- download a box image to your computer
`vagrant box add <name> <url>`
`vagrant box add hashicorp/bionic64`
`vagrant box add bento/debian-12`
`vagrant box add ubuntu/focal64`

-- check for updates vagrant box update
`vagrant box outdated`

-- deletes a box from the machine
`vagrant box remove <name> `

-- packages a running virtualbox env in a reusable box
`vagrant package`

## Tips

-- get the vagrant version
`vagrant -v`

-- outputs status of the vagrant machine
`vagrant status`

-- outputs status of all vagrant machines
`vagrant global-status`

-- same as above, but prunes invalid entries
`vagrant global-status --prune`

-- use the debug flag to increase the verbosity of the output
`vagrant provision --debug`

-- yes, vagrant can be configured to deploy code!
`vagrant push`

-- Runs vagrant up, forces provisioning and logs all output to a file
`vagrant up --provision | tee provision.log`






