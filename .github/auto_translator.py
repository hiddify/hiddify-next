import i18n
import json
from deep_translator import GoogleTranslator
import sys
import os


def get_path(lang):
    if lang == 'en':
        return f'../assets/translations/strings.i18n.json'
    return f'../assets/translations/strings_{lang}.i18n.json'


def read_translate(lang):
    pat = get_path(lang)
    if not os.path.isfile(pat):
        return {}
    with open(pat) as f:
        return json.load(f)


def recursive_translate(src, dst, translator):
    for sk, sv in src.items():
        if type(sv) == str:
            if sk not in dst:
                dst[sk] = translator.translate(sv)
                print(sk, sv, dst[sk])
            if not dst[sk]:
                del dst[sk]
        else:
            if sk not in dst:
                dst[sk] = {}
            recursive_translate(sv, dst[sk], translator)


if __name__ == "__main__":
    src = sys.argv[1]
    dst = sys.argv[2]

    src_pofile = read_translate(src)
    dst_pofile = read_translate(dst)

    translator = GoogleTranslator(source=src, target=dst if dst != 'zh' else "zh-CN")
    recursive_translate(src_pofile, dst_pofile, translator)

    with open(get_path(dst), 'w') as df:
        json.dump(dst_pofile, df)
