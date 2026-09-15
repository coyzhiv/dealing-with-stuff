extends Resource

class_name Skills

@export var title: String
@export var rus_title: String
@export var description: String
@export var rus_description: String
@export var icon: Texture2D
@export var effect: String
@export var effect_info: String
@export var value: float = 0
@export var target: String
@export var upgrade: int = 0
@export var price: Array[int] = [50,100,200,500,1000]
@export var steps: Array[float] = [1,3,5,7,10]
