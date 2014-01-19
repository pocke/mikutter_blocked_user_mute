mikutter_blocked_user_mute
==========================

ブロックしているユーザーをミュートするmikutterプラグインです

## Usage
```sh
$ cd ~/.mikutter/plugin/
$ git clone https://github.com/pocke/mikutter_blocked_user_mute blocked_user_mute
```

ブロックしているユーザーのリストは1時間に一回取得します。  

尚、ブロックしているユーザーが極端に多い(75000ぐらい)と、全てのブロックしているユーザーを取得しきれないと思われます。
API制限が悪い。

`MikuTwitter::APIShortcuts`をモンキーパッチしてます。

Copyright &copy; 2014 pocke
Licensed [MIT][mit]
[MIT]: http://www.opensource.org/licenses/mit-license.php
