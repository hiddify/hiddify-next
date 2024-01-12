from deep_translator import GoogleTranslator
import json
import os
import re
import sys


def get_path(lang):
    base_dir = os.path.abspath('../assets/translations')
    lang_file = f'strings_{lang}.i18n.json'
    path = os.path.join(base_dir, lang_file)
    if path.startswith(base_dir):
        return path
    else:
        raise ValueError('Invalid language file path')


def read_translate(lang):
    pat = get_path(lang)
    if not os.path.isfile(pat):
        return {}
    sanitized_pat = os.path.abspath(pat)
    sanitized_pat = os.path.basename(sanitized_pat)
    with open(sanitized_pat) as f:
        return json.load(f)


def recursive_translate(src, dst, translator):
    for sk, sv in src.items():
        if type(sv) == str:
            if sk not in dst or not dst[sk]:
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

    # Sanitize the dst argument to prevent path traversal
    dst = re.sub(r'[^\w.-]', '', dst)

    src_pofile = read_translate(src)
    dst_pofile = read_translate(dst)

    translator = GoogleTranslator(source=src, target=dst if dst != 'zh' else "zh-CN")
    recursive_translate(src_pofile, dst_pofile, translator)

    with open(os.path.abspath(get_path(dst)), 'w') as df:
        json.dump(dst_pofile, df, ensure_ascii=False, indent=4)
