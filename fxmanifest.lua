-- ╔══════════════════════════════════════════╗
-- ║  Desarrollado por: Fulgencio Zorongo     ║
-- ║  Compañía: La Colmena Group              ║
-- ╚══════════════════════════════════════════╝

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'La Colmena - Border Control System'
author 'Fulgencio Zorongo - La Colmena Group'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'rsg-core',
    'ox_lib',
    'bln_notify',
}

escrow_ignore {
    'config.lua',
    'locales/*.json',
}