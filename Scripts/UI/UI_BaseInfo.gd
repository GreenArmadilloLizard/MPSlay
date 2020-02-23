extends PanelContainer

onready var base_labels = {
	savings = $VBoxContainer/Savings,
	income = $VBoxContainer/Income,
	wages = $VBoxContainer/Wages,
	balance = $VBoxContainer/Balance,
	money = $VBoxContainer/Money
	}

func update_info(base):
	if base != null:
		base_labels.savings.text = "Savings: " + str(base.savings)
		base_labels.income.text = "Income: " + str(base.income)
		base_labels.wages.text = "Wages: " + str(base.wages)
		base_labels.balance.text = "Balance: " + str(base.balance)
		base_labels.money.text = "Money: " + str(base.money)
	else:
		base_labels.savings.text = "Savings: --"
		base_labels.income.text = "Income: --"
		base_labels.wages.text = "Wages: --"
		base_labels.balance.text = "Balance: --"
		base_labels.money.text = "Money: --"
