# Mersenne-Twister-in-AWK
a Mersenne Twister implementation in awk.

* 意外にも、疑似乱数生成器を得意とするはずのArnold Robbinsが実装していなかったようなので、用意しました。
* 2007年にその話が出てから、12年が経過していたわけですが・・・。

* Surprisingly, Arnold Robbins, who should be good at pseudo-random number generators, did not seem to implement it.
* Twelve years have passed since the story came out in 2007 ...


# gawkと他awkの相互互換のための説明
## Description for the mutual compatibility of gawk and other awk
1. systime()関数の代用について  
Substitution of systime () function

	* dateコマンドのunix時刻の出力結果を使用する方法があります。  
	例えば、busyboxのpawkから呼ぶなら、以下のように代用してください。  
	There is a method of using the unix time output result of the date command.  
	For example, if you are calling from busybox pawk, substitute it like this.  
  
  ```
  cmd = "busybox.exe date +%s"
	while(cmd | getline Seed){
	  break;
	}
	close(cmd);
  ```

2. ビット演算について  
About bit operations

	* 論理積、論理和、排他的論理和については、以下のリンクに掲載されている実装を参照してください。
	* チェック機構までは保証しているわけではないので、そのあたりを突き詰めていると時間ばかりかかって仕方がなかったり、
    そのほかのビットシフトなど、アルゴリズムを書くのがしんどい方は、
    bourne shellのletや算術式を「sh -c」でsystem関数で呼んで評価させる手もあります。
    	* 当然ながら、何回もこんなコールをする処理では、当然実行速度には難があるでしょう。

	* For the logical product, logical sum, and exclusive logical sum, refer to the implementation listed in the following link.
	* The check mechanism is not guaranteed, so if you try to find it, it will take time and you can't help it.
	* If it is difficult to write an algorithm such as bit shift, there is also a way to call let and arithmetic expression of bourne shell by "sh -c" with system function and evaluate it.
	* Of course, in the process of making such a call many times, naturally the execution speed will be difficult.

	* 時間城年代記:mawkのためのビット演算関数  
	http://blog.livedoor.jp/kikwai/archives/52263266.html

	* awk と bit 演算（平林浩一）  
	http://www.mogami.com/unix/awk-02.html

