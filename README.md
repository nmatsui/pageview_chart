Pageview Chart
======================
Google Analytics APIから指定した月のPageview TOP10と遷移元ページを取得し、折れ線グラフを作ります。  

下記のカスタマイズしたGarbとGruffを利用します。使い方に従ってgemをローカルインストールしてください。

* [garb (A Ruby wrapper for the Google Analytics API)](https://github.com/nmatsui/garb)
* [gruff (Gruff graphing library for Ruby)](https://github.com/nmatsui/gruff)

使い方
------
1.カスタマイズ済みのgarbをインストールする

    $ git clone git://github.com/nmatsui/garb.git
    $ cd garb
    $ gem build garb.gemspec 
    $ sudo gem install garb-0.9.2.gem

2.カスタマイズ済みのgruffをインストールする（別途ImageMagickとRmagickのインストールが必要です）

    $ git clone git://github.com/nmatsui/gruff.git
    $ sudo gem install hoe
    $ cd gruff
    $ rake package
    $ cd pkg
    $ sudo gem install gruff-0.3.6.gem

3.pageview_chartディレクトリにconfig.yamlを作成する  

    proxy:
      address:  (プロキシサーバのIPアドレス)
      port:     (プロキシサーバのポート)
      user:     (プロキシサーバの認証ユーザ名)
      password: (プロキシサーバの認証パスワード)
    
    garb:
      session:
        user:     (Google Analyticsのユーザ名)
        password: (Google Analyticsのパスワード)
      profile:
        id:       (Google AnalyticsのプロファイルID)
        title:    (プロファイルのタイトル)
    
    gruff:
      font:        (フォント名)
      legend_size: (凡例のサイズ)
      legend_left: (凡例をオーバーラップ表示させない場合の左マージン)
      title_size:  (タイトルのサイズ)

4.実行する
`make_chart.rb yyyy-mm`

ライセンス
----------
Copyright &copy; 2011 nobuyuki.matsui@gmail.com
Licensed under the [GPL license Version 2.0][GPL]

[GPL]: http://www.gnu.org/licenses/gpl.html

