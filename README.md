# Mersenne-Twister-in-AWK
a Mersenne Twister(MT19937, MT19937-64) implementation in awk.

* 意外にも、疑似乱数生成器を得意とするはずのArnold Robbinsが実装していなかったようなので、用意しました。
* 2007年にその話が出てから、12年が経過していたわけですが・・・。
https://rocco.hatenadiary.org/entry/20071126/p1  
アルゴリズムと LL (てか awk) - 日本 GNU AWK ユーザー会 0.2  

* Surprisingly, Arnold Robbins, who should be good at pseudo-random number generators, did not seem to implement it.
* Twelve years have passed since the story came out in 2007 ...


# gawkと他awkの相互互換のための説明
## Description for the mutual compatibility of gawk and other awk
1. systime()関数の代用について  
Substitution of systime () function

	* dateコマンドのUNIX時刻の出力結果を使用する方法があります。  
	例えば、busyboxのpawkから呼ぶなら、以下のように代用してください。  
	There is a method of using the unix time output result of the date command.  
	For example, if you are calling from busybox pawk, substitute it like this.  
  
  ```awk
  cmd = "busybox.exe date +%s";
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

# 使い方
# Usage

```bash
/usr/bin/gawk [-M] -f mersenne_twister.awk -v [Mode=[next/nextInt]] [-v OSBit=[32/64]] [-v Seed=[[:digit:]].*] [-v Min=[[:digit:]].*] [-v Sup=[[:digit:]].*] [-v DecPoint=[[:digit:]].*] [-v SubMode=[int32/int31/real1/real3]]
```

1. Mode
* 任意です。  
* nextかnextIntを指定してください。  
指定のない場合、nextかnextInt以外を指定した場合は、nextを指定したものとみなします。  
next : 0 以上 1 未満の一様分布乱数を1つ返します。  
nextInt : Min以上Sup未満の整数の乱数を1つ返します。  
* Optional.  
* Specify next or nextInt.  
If there is no specification, and if something other than next or nextInt is specified, it is considered that next has been specified.  
next: Returns one uniformly distributed random number between 0 and 1.  
nextInt: Returns an integer random number between Min and Sup.  


2. OSBit
* 任意です。  
* 32か64を指定してください。  
Modeでnextを指定した場合に関わってきます。  
指定のない場合、32か64以外を指定した場合は、32を指定したものとみなします。  
64は、53ビット精度の一様実乱数[0,1)を出力します。  
* Optional.  
* Specify 32 or 64.  
It is related when next is specified in Mode.  
If nothing is specified or 32 or 64 is specified, it is assumed that 32 is specified.  
64 outputs a uniform real random number [0,1) with 53-bit precision.  

3. Seed
* 任意です。  
* 1から2^32未満の数値を指定してください。  
指定のない場合、0の場合、または数字以外の場合、起動時のUNIX時刻が設定されたものとみなします。
* Optional.  
* Specify a number between 1 and 2 ^ 32.  
If not specified, 0, or other than a number, it is assumed that the UNIX time at startup has been set.  

3. Min
* 任意です。  
* 0から2^32 - 1未満の数値を指定してください。    
ModeでnextIntを指定した場合に関わってきます。  
指定のない場合、または数字以外の場合、0が設定されたものとみなします。  
Minが1以上でSupと同一の値が指定された場合、異常終了します。  
Minが1以上でSupより大きい値が指定された場合、Supの値とMinの値を入れ替えて処理を行います。  
* Optional.  
* Specify a number between 0 and 2 ^ 32-1.  
It is related when nextInt is specified in Mode.  
If it is not specified or is not a number, it is assumed that 0 has been set.  
If Min is 1 or more and the same value as Sup is specified, it ends abnormally.  
If Min is greater than 1 and a value greater than Sup is specified, the Sup value and Min value are swapped.  

4. Sup
* 任意です。  
* 1から2^32未満の数値を指定してください。    
ModeでnextIntを指定した場合に関わってきます。  
指定のない場合、0が指定された場合、または数字以外の場合、2^32から1を減じた値、つまり4,294,967,295が設定されたものとみなします。  
* Optional.
* Specify a number between 1 and 2 ^ 32.
It is related when nextInt is specified in Mode.
If it is not specified, 0 is specified, or if it is not a number, it is assumed that 2 ^ 32 minus 1 (4,294,967,295) is set. 

5. DecPoint
* 任意です。
* 1から15の数値を指定してください。  
* Modeでnextを指定した場合に関わってきます。  
* 出力する際の桁数指定に関わってきます。  
指定のない場合、0が指定された場合、または数値以外が指定された場合、6が設定されたものとみなします。  
16以上が指定された場合、15が設定されたものとみなします。  
* Optional.
* Specify a number between 1 and 15.
* It is related when nextInt is specified in Mode.
* This is related to specifying the number of digits when outputting.
If nothing is specified, 0 is specified, or a non-numeric value is specified, 6 is assumed to have been set.
If 16 or more is specified, it is assumed that 15 is set.

6. SubMode
* 任意です。  
* int32、int31、real1、real3のいずれかを指定してください。  
* Modeでnextを指定した場合に関わってきます。  
* 出力の際の除算や減算の方式が変わります。  
* int32は、32ビット精度の一様実乱数[0,1)。  
* int31は、31ビット精度の一様実乱数[0,1)。  
* real1は、32ビット精度の一様実乱数[0,1]。  
* real3は、32ビット精度の一様実乱数(0,1)。  
指定のない場合、int32、int31、real1、real3のいずれか以外が指定された場合、int32が設定されたものとみなします。  

* Optional.  
* Specify int32, int31, real1, or real3.  
* It is related when next is specified in Mode.  
* Division and subtraction methods for output change.  
* int32 is a uniform real random number [0,1) with 32-bit precision.  
* int31 is a uniform real random number [0,1) with 31-bit precision.  
* real1 is a uniform real random number [0,1] with 32-bit precision.  
* real3 is a uniform real random number (0,1) with 32-bit precision.  
If not specified, if any other than int32, int31, real1, or real3 is specified, it is assumed that int32 has been set.  

