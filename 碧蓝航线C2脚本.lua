require "TSLib"
--resolution: 1024*576

tapPos={      --重要点击位置
	{872,526}, --结束战斗后确定按钮坐标
	{510,310}, --boss刷新后的坐标
	{390,473}, --活动页面C2关卡位置
	{792,413}, --点击C2关卡后“立即前往”位置
	{868,484}, --点击立即前往后“立刻前往”位置
	{969,127}, --不在战斗内都是空白位置
	{580,240}  --第一站人形怪坐标
}

enemyPos={ --是否打过1,敌人位置2,3，检查区域x1,y1,x2,y2
		--根据敌人的LV8中的特定0xffffff确定是否有敌人,已经打过就跳过这个
		--敌人在enemyPos表里按照从下到上的顺序排列，优先搜索最下避免被堵路以及被队伍模型挡住
		{false, 592, 475, 577, 488, 643, 512,"D7"}, --D7
		{false, 700, 390, 681, 401, 752, 434,"E6"}, --E6
		{false, 775, 170, 752, 187, 824, 214,"F3"}, --F3
		{false, 674, 173, 658, 181, 710, 209,"E3"}, --E3
		{false, 277, 240, 284, 252, 327, 273,"A4"}, --A4
		{false, 386, 171, 380, 186, 422, 206,"B3"}, --B3
		{false, 300, 138, 297, 128, 326, 141,"A2"} --A2	
}
function screenInit(Pos) --机械比例扩大
	local width, height=getScreenSize() 
	local widthShift=width/1024
	local heightShift=height/576
	for n,v in pairs(Pos) do
		v[1]=v[1]*widthShift;v[2]=v[2]*heightShift;
	end
end
function quitBattle()  --退出战斗
	local quitFlag=false
	local x,y=-1,-1
		while (quitFlag==false)
		do
			--查找退出战斗界面特征
			x,y = findMultiColorInRegionFuzzy( 0xf7e384, "-8|-7|0xfffff7,-4|-6|0xffff9c,-9|-3|0xf7eb8c,4|5|0xeebe73,4|17|0xe6b663,-5|18|0xf7ce63,-8|16|0xe69e84,-11|16|0xe6baa4", 90, 100, 117, 607, 257)
			if(x~=-1) --查找成功
			then
				quitFlag=true
			end
			mSleep(1500) --查找频率
		end
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); --确认战斗结束
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); --确认道具结算
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); --排除船只掉落
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); 
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); --多点几下冗余
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); 
	randomTap(tapPos[1][1],tapPos[1][2],1); mSleep(4000); --点击确定按钮
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); --排除紧急委托
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); 
	randomTap(tapPos[6][1],tapPos[6][2],1); mSleep(500); --冗余
end

battleCounter = 10 --脚本重复次数
for i=1, battleCounter, 1 do
	--screenInit(tapPos) --根据分辨率初始化屏幕
	nLog("预定战斗"..battleCounter.."次,当前为第"..i.."次")
	nLog("正在进入关卡")
	randomTap(tapPos[3][1],tapPos[3][2],1); mSleep(2000) --点击C2关卡图标，等待1.5 
	randomTap(tapPos[4][1],tapPos[4][2],1); mSleep(2000) --点击立即前往，等待1.5
	randomTap(tapPos[5][1],tapPos[5][2],1); mSleep(5000) --点击立刻前往进入关卡，等待5s索敌
	--第一战打人形怪物，等20秒后开始确认是否退出
	nLog("第一战打人形怪")
	randomTap(tapPos[7][1],tapPos[7][2],1); mSleep(20000); quitBattle();
	mSleep(5000);--等待5s索敌
	nLog("人形怪打完了,初始化小怪战斗信息")
	--第二三四战，从下向上查找，优先打下面的
	for a,b in pairs(enemyPos) do --初始化打过信息
		b[1]=false
	end
	local fightCount=0
	for j=1, 3, 1 do
		for n,v in pairs(enemyPos) do
			local x,y=-1,-1 --初始化检查变量
			nLog("现在正在检查的是 "..v[8])
			if(v[1]==false)then --没被打过
				nLog(v[8].." 没被打过")
				x,y=findColorInRegionFuzzy(0xffffff, 100, v[4], v[5], v[6], v[7])
				if(x~=-1)then
					nLog(v[8].." 已查找到,准备战斗")
					randomTap(v[2],v[3],1); mSleep(10000); quitBattle();--打完退出
					mSleep(500)
					v[1]=true --打过了
					mSleep(500)
					fightCount=fightCount+1 --记录成功的战斗次数
					mSleep(500)
					nLog(v[8].." 打完了")
					mSleep(5000) --等待5s索敌
					break
				else
					nLog(v[8].." 未查找到,查找下一个")
					mSleep(500)
				end
			end
		end
		nLog("当前循环次数为"..j.."次，成功的战斗次数为"..fightCount.."次")
		mSleep(1000)
		if (j~=fightCount)then  --本次没找到可打的怪
			nLog("本次没有查找到可打的怪，临时退出")
			lua_exit()
			nLog("已经退出")
		end
	end
	mSleep(1000)
	nLog("准备进入boss战，打完退出")
	randomTap(tapPos[2][1],tapPos[2][2],1); mSleep(20000); quitBattle(); --打boss
	mSleep(5000) --等待退出
end