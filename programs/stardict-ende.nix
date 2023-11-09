# Picked from https://github.com/kmein/niveum/blob/master/configs/stardict.nix
{ pkgs, lib, ... }:
let dictionaries = {
    englishGerman = {
      Etymonline = pkgs.fetchzip {
        url = "http://tovotu.de/data/stardict/etymonline.zip";
        sha256 = "1bjja3n3layfd08xa1r0a6375dxh5zi6hlv7chkhgnx800cx7hxn";
      };
      Roget = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/bigdict/stardict-Roget_s_II_The_New_Thesaurus_3th_Ed-2.4.2.tar.bz2";
        sha256 = "1szyny9497bpyyccf9l5kr3bnw0wvl4cnsd0n1zscxpyzlsrqqbz";
      };
      JargonFile = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/dict.org/stardict-dictd-jargon-2.4.2.tar.bz2";
        sha256 = "096phar9qpmm0fnaqv5nz8x9lpxwnfj78g4vjfcfyd7kqp7iqla4";
      };
      Oxford-Collocations = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/bigdict/stardict-Oxford_Collocations_Dictionary_2nd_Ed-2.4.2.tar.bz2";
        sha256 = "1zkfs0zxkcn21z2lhcabrs77v4ma9hpv7qm119hpyi1d8ajcw07q";
      };
      Langenscheidt-Deu-En = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/babylon/german/stardict-Handw_rterbuch_Deutsch_Englisc-2.4.2.tar.bz2";
        sha256 = "12q9i5azq7ylyrpb6jqbaf1rxalc3kzcwjvbinvb0yabdxb80y30";
      };
      Langenscheidt-En-Deu = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/babylon/german/stardict-Handw_rterbuch_Englisch_Deutsc-2.4.2.tar.bz2";
        sha256 = "087b05h155j5ldshfgx91pz81h6ijq2zaqjirg7ma8ig3l96zb59";
      };
      Duden_Das_Fremdworterbuch = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/babylon/german/stardict-Duden_Das_Fremdworterbuch-2.4.2.tar.bz2";
        sha256 = "1zrcay54ccl031s6dvjwsah5slhanmjab87d81rxlcy8fx0xd8wq";
      };
      Duden_De_De = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/babylon/german/stardict-Duden_De_De-2.4.2.tar.bz2";
        sha256 = "1fhay04w5aaj83axfmla2ql34nb60gb05dgv0k94ig7p8x4yxxlf";
      };
      ConciseOED = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/bigdict/stardict-Concise_Oxford_English_Dictionary-2.4.2.tar.bz2";
        sha256 = "19kpcxbhqzpmhi94mp48nalgmsh6s7rsx1gb4kwkhirp2pbjcyl7";
      };
      Duden_Synonym = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/babylon/german/stardict-Duden_Synonym-2.4.2.tar.bz2";
        sha256 = "0cx086zvb86bmz7i8vnsch4cj4fb0cp165g4hig4982zakj6f2jd";
      };
    };
    HandwoerterbuchEnglischDeutsch = {
      Langenscheidt-En-Deu = pkgs.fetchzip {
        url = "https://web.archive.org/web/20200702000038/http://download.huzheng.org/babylon/german/stardict-Handw_rterbuch_Englisch_Deutsc-2.4.2.tar.bz2";
        sha256 = "087b05h155j5ldshfgx91pz81h6ijq2zaqjirg7ma8ig3l96zb59";
      };
    };
  };

  makeStardictDataDir = dicts: pkgs.linkFarm "dictionaries" (lib.mapAttrsToList (name: path: {inherit name path;}) dicts);

  makeStardict = name: dicts:
    pkgs.writers.writeDashBin name ''
      set -efu
      export SDCV_PAGER=${toString sdcvPager}
      exec ${pkgs.sdcv}/bin/sdcv --color --only-data-dir --data-dir ${makeStardictDataDir dicts} "$@"
    '';

  sdcvPager = pkgs.writers.writeDash "sdcvPager" ''
    export PATH=${lib.makeBinPath [pkgs.gnused pkgs.ncurses pkgs.less]}
    sed "
      s!<sup>1</sup>!¹!gI
      s!<sup>2</sup>!²!gI
      s!<sup>3</sup>!³!gI
      s!<sup>4</sup>!⁴!gI
      s! style=\"color: #...\"!!g;
      s!<span class=\"zenoTXSpaced\">\([^<>]*\)</span>!\1!g;
      s!</\?dictionary[^>]*>!!g;
      s!<style.*</style>!!g;
      s!<author>\([^<>]*\)</author>!\1 !g;
      s!<quote lang=\"\(greek\|la\)\">\([^<>]*\)</quote>!$(tput sitm)\2$(tput sgr0)!g;
      s!<biblScope>\([^<>]*\)</biblScope>!\1!g;
      s!<mood>\([^<>]*\)</mood>!$(tput sitm)\1$(tput sgr0)!g;
      s!<adv>\([^<>]*\)</adv>!$(tput sitm)\1$(tput sgr0)!g;
      s!<gram[^>]*>\([^<>]*\)</gram>!$(tput sitm)\1$(tput sgr0)!g;
      s!<bibl_title>\([^<>]*\)</bibl_title>!$(tput sitm)\1$(tput sgr0) !g;
      s!<hi rend=\"ital\">\([^<>]*\)</hi>!$(tput sitm)\1$(tput sgr0) !g;
      s!<dict_tr>\([^<>]*\)</dict_tr>!$(tput setaf 3)\1$(tput sgr0)!g;
      s!<headword>\([^<>]*\)</headword>!$(tput bold)\1$(tput sgr0)\t!g;
      s!</\?a[^>]*>!!g
      s!</\?[cp]b[^>]*>!!g
      s!</\?gramGrp[^>]*>!!g
      s!</\?lbl[^>]*>!!g
      s!</\?xr[^>]*>!!g
      s!</\?pron[^>]*>!!g
      s!</\?gen[^>]*>!!g
      s!</\?tns[^>]*>!!g
      s!</\?per[^>]*>!!g
      s!</\?blockquote[^>]*>!!g
      s!</\?etym[^>]*>!!g
      s!<foreign[^>]*>!$(tput sitm)!g
      s!</foreign[^>]*>!$(tput sgr0)!g
      s!</\?date[^>]*>!!g
      s!</\?placeName[^>]*>!!g
      s!</\?itype[^>]*>!!g
      s!</\?p>!!g
      s!<input[^>]*>!!g
      s!</\?orth[^>]*>!!g
      s!</\?number[^>]*>!!g
      s!</\?forename[^>]*>!!g
      s!</\?persName[^>]*>!!g
      s!</\?surname[^>]*>!!g
      s!</\?entryFree[^>]*>!!g
      s!</\?def[^>]*>!!g
      s!</\?cit[^>]*>!!g
      s!</\?pos[^>]*>!!g
      s!</\?usg[^>]*>!!g
      s!</\?ul>!!g
      s!<li>!\n!g
      s!</li>!!g
      s!<bibl[^>]*>!$(tput setaf 245)!g
      s!</bibl[^>]*>!$(tput sgr0)!g
      s/<dt>/$(tput bold)/g;
      s:</dt>:$(tput sgr0):g;
      s/<dd>/\n/g;
      s:</dd>::g;
      s:<script>.*</script>::g;
      s/<b>/$(tput bold)/gI;
      s:</b>:$(tput sgr0):gI;
      s:<br\s*/\?>:\n:gI;
      s:<i>:$(tput sitm):gI;
      s:</i>:$(tput sgr0):gI;
      s:<u>:$(tput smul):gI;
      s:</u>:$(tput sgr0):gI;
      s:<FONT face=[^>]*>::g;
      s:</FONT>::g;
      s!<head>\([^<>]*\)</head>!$(tput bold)\1$(tput sgr0)!g;
      s!<span lang=\"\(gr\|la\)\">\([^<>]*\)</span>!\2!g
      s#<div style=\"margin-left:1em\">\(.*\)</div>#\\1#g;
      s:<font color=\"brown\">\([^<>]*\)</font>:$(tput setaf 3)\\1$(tput sgr0):g;
      s:<font color=\"blue\">\([^<>]*\)</font>:$(tput setaf 4)\\1$(tput sgr0):g;
      s:<font color=\"red\">\([^<>]*\)</font>:$(tput setaf 1)\\1$(tput sgr0):g;
      s:<font color=\"darkviolet\">\([^<>]*\)</font>:$(tput setaf 5)\\1$(tput sgr0):g;
      s:<font color=\"#a0a\">\([^<>]*\)</font>:$(tput bold)\1$(tput sgr0):g
      s:<font color=\"#838\">\([^<>]*\)</font>:$(tput setaf 3)\1$(tput sgr0):g
      s:&#x27;:':g
      s:&lt;:<:g
      s:&gt;:>:g
      s:<font color=\"#007000\">\([^<>]*\)</font>:$(tput setaf 2)\\1$(tput sgr0):g;
      s:<font color=\"#007000\">\([^<>]*\)</font>:$(tput setaf 2)\\1$(tput sgr0):g;
      s:<font color=#000099>\([^<>]*\)</font>:$(tput setaf 4)\\1$(tput sgr0):g;
      s:<font color=0000FF>\([^<>]*\)</font>:$(tput bold)\\1$(tput sgr0):g;
      s:<IMG src=\"223E9A06.bmp\"[^>]*>:ː:g;
      s:<IMG src=\"502F5DDA.bmp\"[^>]*>::g;
      s:<IMG src=\"8DAD7054.bmp\"[^>]*>:n̩:g
      s!</\?TABLE>!!gI
      s!</\?TR[^>]*>!!gI
      s!</\?TD>!!gI
      s!</\?FONT[^>]*>!!gI
      s!</\?A[^>]*>!!gI
      s!<SPAN class=\"bsptext\">\([^<>]*\)</SPAN>!$(tput setaf 245)\1$(tput sgr0)!g
      s! +! !g;
      s!<div part=\"[^\"]*\">!\n\n&!g
      s!<sense n=\"\([^\"]*\)\"!\n$(tput setaf 5)\1.$(tput sgr0) &!g;
      s!</\?sense[^>]*>!!g
      s!</\?div[^>]*>!!g
      s!<span lang=\"gr\">!!g # unbalanced in Frisk
      s!^\s*[0-9])!$(tput setaf 5)&$(tput sgr0)!g
      s!</\?span[^>]*>!!gI
      s!</\?p[^>]*>!!gI
    " | less -FR
  '';

in {
  ende-full = makeStardict "ende-full" dictionaries.englishGerman;
  ende = makeStardict "ende" dictionaries.HandwoerterbuchEnglischDeutsch;
}
