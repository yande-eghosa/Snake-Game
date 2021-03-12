import kivy
from kivymd.app import MDApp

from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.widget import Widget
from kivy.uix.scatter import Scatter
from kivymd.uix.label import MDLabel

from kivy.lang import Builder
from kivy.core.window import Window
from kivy.clock import Clock
from kivy.properties import *
from kivy.animation import Animation

from math import asin, acos, degrees
from random import randint
import os

Builder.load_file('tools.kv')

class MainMenu(Screen):
	
	def start_game(self):
		self.manager.add_widget(Game())
		self.manager.current='game'

class Game(Screen):
	head_pos_x = NumericProperty()
	head_pos_y = NumericProperty()
	score= NumericProperty(0)
	food_pos = ListProperty([300,500])
	snake_speed= ListProperty()
	snake_parts= ListProperty()

	def __init__(self, **kwargs):
		super(Game, self).__init__(**kwargs)
		self.head_pos_x = Window.width/2
		self.head_pos_y = Window.height/2
		self.snake_speed=[7,0] if kivy.platform != 'win' else [2,0]
		self.rcolor=1
		self.isDead=False
		Clock.schedule_once(self.init)
	
	def init(self,*a):
		self.ids.box.bind(on_touch_down=self.finger_down)
		self.ids.box.bind(on_touch_up=self.finger_up)
		self.xxx=Clock.schedule_interval(self.move_head, 1/60)
		self.ids.food.blink()
		
	def move_head(self,*args):
		old_pos=[self.ids.head.x,self.ids.head.y]
		self.head_pos_x += self.snake_speed[0]
		self.head_pos_y += self.snake_speed[1]
		self.move_tail(old_pos)
		self.hasHitWall()
		self.eatFood()
	
	def move_tail(self,new_pos):
		width=self.ids.head.width
		height=self.ids.head.height
		old_pos=False
		for i in self.snake_parts:
			if not old_pos:
				old_pos=[i.x,i.y]		
			else:
				new_pos=old_pos
				old_pos=[i.x,i.y]
			i.pos=[new_pos[0],new_pos[1]]
	
	def grow_snake(self,*a):
		new_tail=Tail()
		new_tail.rcolor=self.rcolor
		self.rcolor-=.1
		self.snake_parts.append(new_tail)
		self.ids.box.add_widget(new_tail)

	def finger_down(self,box,touch):
		if self.isDead:
			return
		self.pos_1=touch.spos
		
	def finger_up(self,box,touch):
		if self.isDead:
			return
		self.pos_2=touch.spos
		self.calculate_angle()
	
	def calculate_angle(self):
		x2, y2 = self.pos_2
		x1, y1 = self.pos_1
		try:
			sine =(y2-y1)/(((y2-y1)**2)+((x2-x1)**2))**0.5
			is_right= True if x2>x1 else False
			is_up= True if y2>y1 else False
		except:#invalid touch
			return
	
		angle=degrees(asin(sine))
		self.change_direction(self.get_direction(angle,is_right,is_up))
	
	def eatFood(self):
		if self.ids.head.collide_widget(self.ids.food):
			for i in self.snake_speed:
				if i !=0:
					self.snake_speed[self.snake_speed.index(i)]*=1.1
			self.change_food_pos()
			self.grow_snake()
			self.score+=10
			self.ids.score_label.text=f'Score: {self.score}'
	
	def change_food_pos(self,*a):
		maxX,maxY= self.ids.box.size
		foodx = randint(0,maxX-self.ids.food.width)
		foody = randint(0,maxY-self.ids.food.height)
		self.food_pos=[foodx,foody]

	def hasHitWall(self):
		maxX,maxY=self.ids.box.size
		x, y = self.ids.head.pos
		top, right=self.ids.head.top, self.ids.head.right
		points=[x,y,top,right]
		if x<0 or right>maxX or y<0 or top > maxY:
			#You hit the wall
			self.isDead=True
			import time
			time.sleep(1)
			self.snake_speed=[0,0]
			self.xxx.cancel()
			from kivymd.uix.dialog import MDDialog
			MDDialog(title=f'You hit the wall!!!\nScore: {self.score} points').open()
			self.clear_widgets()
			self.manager.current='mainmenu'
	
	def change_direction(self,d):
		for i in self.snake_speed:
			if i !=0:
				isY=self.snake_speed.index(i)			
		
		if d==1 or d==3:
			if isY:
				self.snake_speed.reverse()
				speed=self.snake_speed[isY-1]
				if d==1:
					speed= speed if not '-' in str(speed) else speed*-1
				else:
					speed= speed if '-' in str(speed) else speed*-1
				self.snake_speed[isY-1]=speed
		elif d==2 or d==4:
			if not isY:
				self.snake_speed.reverse()
				speed=self.snake_speed[isY+1]
				if d==2:
					speed= speed if not '-' in str(speed) else speed*-1
				else :
					speed= speed if '-' in str(speed) else speed*-1
				self.snake_speed[isY+1]=speed
	
	def get_direction(self,angle,is_right,is_up):
		if angle<45 and angle > -45:
			if is_right:
				return 1#'right'
			else:
				return 3#'left'
		if angle>=45 or angle <=-45:
			if is_up:
				return 2#'up'
			else:
				return 4#'down'
			
class Tail(Scatter):
	rcolor=NumericProperty()#i use this property to control the opacity of the snake tail
		
class Head(Scatter):
	pass

class Food(Scatter):
	alphaz=NumericProperty(1)
	
	def blink(self):
		anim=Animation(alphaz=1,d=.5)+Animation(alphaz=.1)
		anim.repeat=True
		anim.start(self)

class Sm(ScreenManager):
	pass

class SnakeApp(MDApp):
	def build(self):
		self.theme_cls.primary_palette = 'Red'
		return Sm()

if __name__ == '__main__':
	SnakeApp().run()
