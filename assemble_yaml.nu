def normalize-text [] {
    str replace -ra '\\r?\\n\s*' (char nl)
    | str replace -a '&mdash;' '--'
    | str replace -a '&amp;' '&'
    | str replace -a "\t" ' '
    | str replace -a '\n' (char nl) # Thanissaro Bhikkhu
    | lines
    | str trim
    | to text
}

def compose_dhamma [
    path: path
    translator: string
    license: string
] {
    let chapters = open meta_chapters.json | items {|k v| {chapter: $k, chapter_title: $v.english}} | into int chapter
    let verses = open text_dhammapada.json | items {|k v| {verse: $k chapter: $v.chapter}} | into int chapter verse
    let verses_text = open $path
        | items {|k v| {verse: $k, verse_text: $v}}
        | update verse_text { normalize-text }
        | into int verse

    let dhamma_table = $chapters | join $verses chapter | join $verses_text verse

    $dhamma_table
    | group-by chapter
    | values
    | each {|i|
        {$i.0.chapter: {
            number: $i.0.chapter,
            title: $i.0.chapter_title
            verses: ($i | each {|v| {number: $v.verse verse: $v.verse_text}})
        }}
    }
    | values
    | flatten
    | {title: Dhammapada translator: $translator license: $license chapters: $in}
}

cd text
mkdir ../yaml

let translations = open meta_translators.json

glob trans*.json
| wrap path
| insert label {get path | parse -r '_(.*)\.json' | get capture0.0}
| insert fields {|i| $translations | get $i.label | select name license | rename translator}
| flatten
| each {|i| compose_dhamma $i.path $i.translator $i.license | save -f $'../yaml/dhammapada_($i.label).yaml'}


let chapters = open meta_chapters.json | items {|k v| {chapter: $k, chapter_title: $v.pali}}

open text_dhammapada.json
| items {|k v| {verse: $k chapter: $v.chapter verse_text: $v.text}}
| update verse_text {normalize-text}
| join $chapters chapter
| group-by chapter
| values
| each {|i|
    {$i.0.chapter: {
        number: ($i.0.chapter | into int),
        title: $i.0.chapter_title
        verses: ($i | each {|v| {number: ($v.verse | into int) verse: $v.verse_text}})
    }}
} | values
| flatten
| {title: Dhammapada chapters: $in}
| save -f '../yaml/dhammapada_pali.yaml'
