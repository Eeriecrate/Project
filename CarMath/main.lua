function love.load()
	math.randomseed(os.time());
	utf8 = require("utf8")
	Start = love.graphics.newFont("Font.ttf", 30) --Change this to something with a different copyright at some point.
	Arrows = love.graphics.newFont("Font.ttf",15);
	love.graphics.setBackgroundColor(40,43,42);
	newEnemy_Cooldown = 5.0;
	maxFamily = 1000;
	minFamily = 0;
	mathFunctions = require("mathfunctions");
	Questions = {}
	Questions[1] = {};
	Questions[1].First = 0;
	Questions[1].Second = 0;
	Questions[2] = {};
	Questions[2].First = 0;
	Questions[2].Second = 0;

	LArrow = love.graphics.newImage("Images/LeftArrow.png");
	RArrow = love.graphics.newImage("Images/RightArrow.png");
	Car = love.graphics.newImage("Images/PlayerCar.png");
	EnemyCar = love.graphics.newImage("Images/EnemyCar.png");
	EnemySpeed = 100;
	Started = false;
	Lines = {};
	Score = 0.0;

	Button = {};
	Button.Size = {};
	Button.Size.X = 100;
	Button.Size.Y = 40
	Button.Position = {};
	Button.Position.X = 150;
	Button.Position.Y = 280;

	Scoreb = {};
	Scoreb.Size = {};
	Scoreb.Size.X = 100;
	Scoreb.Size.Y = 20;
	Scoreb.Position = {};
	Scoreb.Position.Y = 0;
	Scoreb.Position.X = 300;

	Input = {};
	Input.Position = {};
	Input.Position.X = 150;
	Input.Position.Y = 558;
	Input.Size = {};
	Input.Size.Y = 25;
	Input.Size.X = 100;
	Input.Text = "";


	function love.textinput(t)
		Input.Text = Input.Text..t;
	end

	function checkAnswer()
		local Left = Questions[1].First+Questions[1].Second;
		local Right = Questions[2].First+Questions[2].Second;
		if tonumber(Input.Text) == Left then
			changeLane("left");
			setQuestions();
		elseif tonumber(Input.Text) == Right then
			changeLane("right");
			setQuestions();
		end
	end

	function love.keypressed(key)
	    if key == "backspace" then
	        local byteoffset = utf8.offset(Input.Text, -1)
	        if byteoffset then
	            Input.Text = string.sub(Input.Text, 1, byteoffset - 1)
	        end
	    elseif key == "return" then
	    	checkAnswer();
	    	Input.Text = "";
	    end
	end


	function setQuestions()
		Questions[1].First = math.random(minFamily,maxFamily);
		Questions[1].Second = math.random(minFamily,maxFamily);
		Questions[2].First = math.random(minFamily,maxFamily);
		Questions[2].Second = math.random(minFamily,maxFamily);
		if (Questions[1].First + Questions[1].Second == Questions[2].First + Questions[2].Second) then
			setQuestions();
		end
	end

	for i = 0,3,1 do
		local Line = {};
		Line.Size = {};
		Line.Size.X = 10;
		Line.Size.Y = 50;
		Line.Position = {};
		Line.Position.X = 145;
		Line.Position.Y = (i*162.5)+12.5;
		table.insert(Lines,Line);
	end
	for i = 0,3,1 do
		local Line = {};
		Line.Size = {};
		Line.Size.X = 10;
		Line.Size.Y = 50;
		Line.Position = {};
		Line.Position.X = 242.5;
		Line.Position.Y = (i*162.5)+12.5;
		table.insert(Lines,Line);
	end
	Lanes = {};
	Lanes.Middle = 200 - (75/2);
	Lanes.Left = 60;
	Lanes.Right = 350 - 85;
	Player = {};
	function newPlayer()
		Player = {};
		Player.Lane = "Middle";
		Player.Size = {};
		Player.Size.X = 75;
		Player.Size.Y = 125;
		Player.Position = {};
		Player.Position.X = Lanes.Middle;
		Player.Position.Y = 600 - (150);
		Player.Image = Car;
		return Player;
	end
	Player = newPlayer();
end


function love.mousepressed(x,y,button)
	v = Button;
	if not Started then
	 	if ((x > v.Position.X and x < v.Position.X + v.Size.X) and (y > v.Position.Y and y < v.Position.Y + v.Size.Y)) then
			Player = newPlayer();
			Enemies = {};
			newEnemy_Cooldown = 5.0;
			setQuestions();
			Score = 0.0;
			Started = true;
		end
	end
end

function isTouching()
	hasFound = false;
	for i,v in pairs(Enemies) do
		if ((((Player.Position.X + Player.Size.X) > (v.Position.X)) and ((Player.Position.X < (v.Position.X + v.Size.X)))) and (((Player.Position.Y + Player.Size.Y) > (v.Position.Y)) and ((Player.Position.Y < (v.Position.Y + v.Size.Y))))) then
			v.Touched = true;
			Started = false;
			hasFound = true;
		else
			v.Touched = false;
		end
	end
	return  hasFound;
end

function countDown_Enemies(increment)
	newEnemy_Cooldown = newEnemy_Cooldown - increment
	if newEnemy_Cooldown <= 0 then
		newEnemies();
		newEnemy_Cooldown = 600/EnemySpeed;
	end
end
Enemies = {};
function newEnemies()
	local Ava = {};
	for i,v in pairs(Lanes) do
		table.insert(Ava,v);
	end
	for i = 1,2 do
		Choice = math.random(1,#Ava);
		Enemy = {};
		Enemy.Touched = false;
		Enemy.Size = {};
		Enemy.Size.X = 75;
		Enemy.Size.Y = 125;
		Enemy.Position = {};
		Enemy.Position.X = Ava[Choice];
		Enemy.Position.Y = -125;
		table.remove(Ava,Choice);
		table.insert(Enemies,Enemy);
	end
end

function changeLane(key)
	if key == "left" then
		if Player.Lane == "Middle" then
			Player.LastLane = "Middle"
			Player.Lane = "Left";
		elseif Player.Lane == "Right" then
			Player.LastLane = "Right";
			Player.Lane = "Middle";
		end
	elseif key == "right" then
		if Player.Lane == "Middle" then
			Player.LastLane = "Middle"
			Player.Lane = "Right";
		elseif Player.Lane == "Left" then
			Player.LastLane = "Left";
			Player.Lane = "Middle";
		end
	end
end
function love.update(z)
	if Started then
		love.graphics.setFont(Start);
		Score = Score + (z*100);
		for i,v in pairs(Enemies) do
			v.Position.Y = v.Position.Y + (EnemySpeed*(z))
			if v.Position.Y >= 600 then
				table.remove(Enemies,i);
			end
		end
		countDown_Enemies(z);
		if Player.Lane == "Middle" and (Player.Position.X ~= Lanes.Middle) then
			if math.abs(Player.Position.X - Lanes.Middle) <= 5 then
				Player.Position.X = Lanes.Middle;
			else
				if Player.Position.X < Lanes.Middle then
					Player.Position.X = Player.Position.X + ((Lanes.Middle - Lanes.Left)*(z*2));
				elseif Player.Position.X > Lanes.Middle then
					Player.Position.X = Player.Position.X - ((Lanes.Right - Lanes.Middle)*(z*2));
				end
			end
		elseif Player.Lane == "Left" and (Player.Position.X ~= Lanes.Left) then
			if math.abs(Player.Position.X - Lanes.Left) <= 5 then
				Player.Position.X = Lanes.Left;
			else
				if Player.Position.X > Lanes.Left then
					Player.Position.X = Player.Position.X - ((Lanes.Middle - Lanes.Left)*(z*2));
				end
			end
		elseif Player.Lane == "Right" and (Player.Position.X ~= Lanes.Right) then
			if math.abs(Player.Position.X - Lanes.Right) <= 5 then
				Player.Position.X = Lanes.Right;
			else
				if Player.Position.X < Lanes.Right then
					Player.Position.X = Player.Position.X - ((Lanes.Middle - Lanes.Right)*(z*2));
				end
			end
		end
		for i,v in pairs(Lines) do
			v.Position.Y = v.Position.Y + (450*(z));
			if v.Position.Y >= 600 then
				v.Position.Y = -50;
			end
		end
	end
end

function love.draw()
	if not Started then
		love.graphics.setColor(0,0,0);
		love.graphics.rectangle("fill",Button.Position.X,Button.Position.Y,Button.Size.X,Button.Size.Y);
		love.graphics.setColor(255,255,255);
		love.graphics.print("START",(Button.Position.X+(Button.Size.X/2))-love.graphics.getFont():getWidth("START")/2,Button.Position.Y+4);
	end
	love.graphics.setColor(95,71,47);
	love.graphics.rectangle("fill",0,0,50,600);
	love.graphics.rectangle("fill",350,0,50,600);
	for i = 0,10,1 do
	love.graphics.setColor(61/2,84/(1+(0.05*i)),47/2);
	love.graphics.rectangle("fill",0,0,45-(5*i),600);
	love.graphics.rectangle("fill",355+(5*i),0,45,600);
	end
	love.graphics.setColor(255,255,255);
	for i,v in pairs(Lines) do
		love.graphics.rectangle("fill",v.Position.X,v.Position.Y,v.Size.X,v.Size.Y);
	end
	for i,v in pairs(Enemies) do
		love.graphics.setColor(0,0,0,255/2);
		local Angle = mathFunctions.getAngleTo(mathFunctions.packageLocation(v.Position.X+(75/2),v.Position.Y+(125/2)),mathFunctions.packageLocation(200,0));
		local SX = v.Position.X + (math.cos(Angle) * 40)*-1;
		if v.Position.X == Lanes.Middle then
			SY = v.Position.Y + (math.sin(Angle) * 10)*1;
		else
			SY = v.Position.Y + (math.sin(Angle) * 10)*-1;
		end
		love.graphics.draw(EnemyCar,SX,SY);
		love.graphics.setColor(255,255,255);
		if v.Touched then
			love.graphics.setColor(50,50,50);
		end
		love.graphics.draw(EnemyCar,v.Position.X,v.Position.Y);
	end
	love.graphics.setColor(0,0,0,255/2);
	local Angle = mathFunctions.getAngleTo(mathFunctions.packageLocation(Player.Position.X+(75/2),Player.Position.Y+(125/2)),mathFunctions.packageLocation(200,0));
	local SX = Player.Position.X + (math.cos(Angle) * 40)*-1;
	if Player.Position.X == Lanes.Middle then
		SY = Player.Position.Y + (math.sin(Angle) * 10)*1;
	else
		SY = Player.Position.Y + (math.sin(Angle) * 10)*-1;
	end
	love.graphics.draw(Player.Image,SX,SY);
	love.graphics.setColor(255,255,255);
	if isTouching() then
		--[[Anything that should happen after a crash.]]--
		love.graphics.setColor(50,50,50);
	end
	love.graphics.draw(Player.Image,Player.Position.X,Player.Position.Y);
	love.graphics.setColor(255,255,255);
	love.graphics.draw(LArrow,0,550);
	love.graphics.draw(RArrow,250,550);
	love.graphics.rectangle("fill",Input.Position.X,Input.Position.Y,Input.Size.X,Input.Size.Y);
	love.graphics.setColor(0,0,0);
	love.graphics.setFont(Arrows);
	love.graphics.print(Input.Text,(Input.Position.X+(Input.Size.X/2))-love.graphics.getFont():getWidth(Input.Text)/2,Input.Position.Y+4);
	love.graphics.print(Questions[1].First.."+"..Questions[1].Second,(0+(150/2))-love.graphics.getFont():getWidth((Questions[1].First.."+"..Questions[1].Second))/2,550+13)
	love.graphics.print(Questions[2].First.."+"..Questions[2].Second,(250+(150/2))-love.graphics.getFont():getWidth((Questions[2].First.."+"..Questions[2].Second))/2,550+13)
	love.graphics.setColor(0,0,0,255-(255*.99));
	for i = 0,99,1 do
		love.graphics.rectangle("fill",i,0,400,100-(i*1));
	end
	love.graphics.setColor(255,255,255);
	love.graphics.rectangle("fill",Scoreb.Position.X,Scoreb.Position.Y,Scoreb.Size.X,Scoreb.Size.Y);
	love.graphics.setColor(0,0,0);
	love.graphics.print(math.floor(Score),(Scoreb.Position.X+(Scoreb.Size.X/2))-love.graphics.getFont():getWidth(math.floor(Score))/2,Scoreb.Position.Y+4);
	love.window.setTitle(love.timer.getFPS( ))
end