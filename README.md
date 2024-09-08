# Dhammapada

Nushell script to assemble yaml texts for Dhammapada and its translations.

Simple cyberlinks

```nu
glob *.yaml
| each {|i|
    let cid = (cy pin-text 'dhammapada yaml');
    cy link-texts $cid (open $i -r)
}

cy link-texts 'dhammapada' 'dhammapada yaml'
```
