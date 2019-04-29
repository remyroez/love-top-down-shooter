<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.2" tiledversion="1.2.3" name="tilesheet" tilewidth="64" tileheight="64" tilecount="540" columns="27">
 <image source="../game/assets/tilesheet.png" width="1728" height="1280"/>
 <terraintypes>
  <terrain name="grass" tile="0"/>
  <terrain name="white-line" tile="39"/>
  <terrain name="yellow-line" tile="32"/>
  <terrain name="soil" tile="4"/>
 </terraintypes>
 <tile id="0" terrain="0,0,0,0" probability="0.25"/>
 <tile id="1" terrain="0,0,0,0" probability="0.25"/>
 <tile id="2" terrain="0,0,0,0" probability="0.25"/>
 <tile id="3" terrain="0,0,0,0" probability="0.25"/>
 <tile id="4" terrain="3,3,3,3" probability="0.5"/>
 <tile id="5" terrain="3,3,3,3" probability="0.5"/>
 <tile id="6" probability="0.5"/>
 <tile id="7" probability="0.5"/>
 <tile id="27" terrain=",2,,2"/>
 <tile id="28" terrain="2,,2,"/>
 <tile id="29" terrain=",,2,2"/>
 <tile id="30" terrain="2,2,2,"/>
 <tile id="31" terrain="2,2,,2"/>
 <tile id="32" terrain=",,,2"/>
 <tile id="33" terrain=",,2,"/>
 <tile id="34" terrain=",1,,1"/>
 <tile id="35" terrain="1,,1,"/>
 <tile id="36" terrain=",,1,1"/>
 <tile id="37" terrain="1,1,1,"/>
 <tile id="38" terrain="1,1,,1"/>
 <tile id="39" terrain=",,,1"/>
 <tile id="40" terrain=",,1,"/>
 <tile id="56" terrain="2,2,,"/>
 <tile id="57" terrain="2,,2,2"/>
 <tile id="58" terrain=",2,2,2"/>
 <tile id="59" terrain=",2,,"/>
 <tile id="60" terrain="2,,,"/>
 <tile id="63" terrain="1,1,,"/>
 <tile id="64" terrain="1,,1,1"/>
 <tile id="65" terrain=",1,1,1"/>
 <tile id="66" terrain=",1,,"/>
 <tile id="67" terrain="1,,,"/>
 <tile id="85" terrain="2,2,2,2"/>
 <tile id="92" terrain="1,1,1,1"/>
 <tile id="128">
  <objectgroup draworder="index">
   <object id="1" x="5" y="5" width="54" height="54"/>
  </objectgroup>
 </tile>
 <tile id="180">
  <objectgroup draworder="index">
   <object id="1" x="32" y="32" width="64" height="64">
    <ellipse/>
   </object>
  </objectgroup>
 </tile>
 <tile id="181">
  <objectgroup draworder="index">
   <object id="1" x="-32" y="32" width="64" height="64">
    <ellipse/>
   </object>
  </objectgroup>
 </tile>
</tileset>
