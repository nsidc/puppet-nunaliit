A puppet module to install nunaliit and manage atlases.

To use, add a nunaliit installation and an atlas to your manifest.

Example in hiera yaml format :
```shell
classes:
  nunaliit

nunaliit::installs:
  2.2.3: {}
  2.2.2: {}

nunaliit::atlases:
  example:
    create: true
    nunaliit_version: 2.2.3
    atlas_parent_directory: /tmp
    docs: /vagrant/atlases/example/docs
    htdocs: /vagrant/atlases/example/htdocs
    config: /vagrant/atlases/example/config
```

## Defined Types & Classes

---
### nunaliit::install
This defined type downloads and unpacks the specified version of nunaliit into /opt

### `nunaliit_version`
The version of nunaliit

---
### nunaliit::atlas
This defined type manages a nunaliit atlas and creates it if necessary.

### `create=false`
Whether or not to create the atlas if it doesn't already exist

### `nunaliit_version`
The version of nunaliit required by this atlas

### `atlas_parent_directory`
The parent directory for the atlas directory. The atlas directory itself is always named after the atlas.

### `docs`
A directory on the VM to sync into the atlas docs folder. 
This will erase the contents of the docs folder and run "nunaliit update" afterward.

### `htdocs`
A directory on the VM to sync into the atlas htdocs folder. 
This will erase the contents of the htdocs folder and run "nunaliit update" afterward.

### `config`
A directory on the VM to sync into the atlas config folder. 
Files of the same name are overwritten, but any other existing files are left unmodified.

