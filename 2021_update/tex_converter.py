# -*- coding: utf-8 -*-
#!/usr/bin/python

import unicode_tex as utex


def replace_tex_character(k, pos, name):
    length = len(k)
    new_name = name[:pos] + utex.tex_to_unicode_map.get(k, k) + name[pos+length:]
    return new_name


def strlen(s):
    return len(s)


def convert_tex_string(name):
    for k in sorted(utex.tex_to_unicode_map, key=strlen, reverse=True):
        if not k.startswith('\\'):
            continue
        v = utex.tex_to_unicode_map[k]
        pos = name.find(k)
        while pos > (-1):
            # print "Found matching tex character: %s at position %s" % (k, pos)
            name = replace_tex_character(k, pos, name)
            pos = name.find(k)

    return name.encode(encoding='utf8')