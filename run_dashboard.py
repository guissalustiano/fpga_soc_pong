from dash import Dash, html, dash_table
import pandas as pd
import firebase_admin
from firebase_admin import credentials, db

cred = credentials.Certificate("soc-pong-firebase-adminsdk-4r3nm-63b21be0ee.json")
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://soc-pong-default-rtdb.firebaseio.com/'
})
ref = db.reference('/scores')

app = Dash(__name__)

def gera_tabela():
    dict_hist_raw = ref.get()
    df_list = []
    for item in dict_hist_raw.values():
        line_dict = {
            'Tempo de fim da partida':item['createAt'],
            'Pontuação da esquerda':item['left']['score'],
            'Esquerda venceu':item['left']['win'],
            'Pontuação da direita':item['right']['score'],
            'Direita venceu':item['right']['win']
        }
        df_list.append(line_dict)
    df_hist = pd.DataFrame(df_list)

    # Metricas
    metricas = html.Div([
        html.P('Média de pontuação da esquerda: {0}'.format(round(df_hist['Pontuação da esquerda'].mean(), 3))),
        html.P('Média de pontuação da direita: {0}'.format(round(df_hist['Pontuação da direita'].mean(), 3))),
        html.Hr(style={'background-color':'black', 'height': '1.5px', 'border':'none'}),
        html.P('Taxa de vitórias da esquerda: {0}'.format(round(df_hist['Esquerda venceu'].mean(), 3))),
        html.P('Taxa de vitórias da direita: {0}'.format(round(df_hist['Direita venceu'].mean(), 3)))
        ],
        style={'font-size':'18pt'}
    )

    tab_hist = dash_table.DataTable(df_hist.to_dict('records'), [{"name": i, "id": i} for i in df_hist.columns])

    return metricas, tab_hist

def serve_layout():
    metricas, tab_hist = gera_tabela()

    return html.Div(children=[
        html.H1('SoC Pong - Histórico de pontuações', style={'font-family': 'Helvetica, Arial, sans-serif'}),
        html.Hr(style={'background-color':'black', 'height': '2px', 'border':'none'}),

        html.Div(children=[tab_hist], style={'margin':'0px 100px 0px'}),

        html.Hr(style={'background-color':'black', 'height': '2px', 'border':'none'}),

        html.Div(
            id='metricas-teste',
            children=[metricas],
            style={
                'font-family': 'Helvetica, Arial, sans-serif',
                'border-style': 'solid',
                'margin-left':'10% ',
                'margin-right':'10% ',
                'border-radius':'10px',
                'background-color':'#f0f0f0',
                })
        ],

        style={'text-align':'center'}
    )

app.layout = serve_layout

if __name__ == '__main__':
    app.run_server(debug=True)