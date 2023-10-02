import i18n
import json
from deep_translator import GoogleTranslator
import sys


def get_path(lang):
    if lang == 'en':
        return f'assets/translations/strings.i18n.json'
    return f'assets/translations/strings_{lang}.i18n.json'


def recursive_translate(src, dst, translator):
    for sk, sv in src.items():
        if type(sv) == str and sk not in dst:
            dst[sk] = translator.translate(sv)
            if not dst[sk]:
                del dst[sk]
        else:
            if sk not in dst:
                dst[sk] = {}
            recursive_translate(sv, dst[sk], translator)


if __name__ == "__main__":
    src = sys.argv[1]
    dst = sys.argv[2]

    src_file = get_path(src)
    dst_file = get_path(dst)
    with open(src_file) as sf:
        src_pofile = json.load(sf)
    with open(dst_file) as df:
        dst_pofile = json.load(df)
    translator = GoogleTranslator(source=src, target=dst if dst != 'zh' else "zh-CN")
    recursive_translate(src_pofile, dst_pofile, translator)

    with open(dst_file, 'w') as df:
        json.dump(dst_pofile, df)
