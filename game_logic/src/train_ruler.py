from sklearn.ensemble import RandomForestClassifier
import pandas as pd
import random as rd
import numpy as np
import pickle

sizes = [8,16,32,64]


def generate_data(n=500000):
    x = pd.DataFrame(
        {
            'pos_x': [rd.randint(-10, 70) for i in range(n)],
            'pos_y': [rd.randint(-10, 70) for i in range(n)],
            'cell_value': [rd.randint(-3, 3) for i in range(n)],
            'board_size': [sizes[rd.randint(0, 3)] for i in range(n)],
            'ite': [rd.randint(-10, 120) for i in range(n)],
        }
    )

    y = pd.DataFrame({
        'target': [1 for i in range(n)]
    })
    y.target[x.pos_x < 0] = 0
    y.target[x.pos_y < 0] = 0
    y.target[x.pos_x > x.board_size] = 0
    y.target[x.pos_y > x.board_size] = 0
    y.target[x.cell_value < 0] = 0
    y.target[x.cell_value > 1] = 0
    y.target[x.ite < 0] = 0
    y.target[x.ite >= 100] = 2

    return x, y


x, y = generate_data()
x_test, y_test = generate_data(50000)

rnf = RandomForestClassifier(max_depth=10, n_estimators=500, random_state=0)
rnf.fit(x, y.target)

preds = rnf.predict(x_test)
print(np.mean(preds == y_test.target))
print(set(preds))
with open("rnf.model", 'wb') as file:
    pickle.dump(rnf, file)