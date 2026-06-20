import time

def inp(texto):
    return input(texto)

alunos = {
    "Matheus": "0e000a",
    "Vitor": "0e000b",
    "Ricardo": "0e000c"
}

notas_lancadas = {}

print("   Seja bem vindo(a)")
time.sleep(1)
print("   Preencha as informações abaixo:")
time.sleep(1)

nome = inp("   Nome: ")
if nome == "test":
    print("   test está no sistema")
else:
    print("   Este nome não está no sistema.")
    exit()

time.sleep(0.8)

cpf = inp("   CPF: ")
if cpf == "00000000000":
    print("   Esse CPF está no sistema")
else:
    print("   Este CPF não está no sistema.")
    exit()

time.sleep(0.8)

materia = inp("   Matéria: ")
if materia == "Matematica":
    print("   Matemática é sua área profissional")
else:
    print("   Esta não é sua área profissional")
    exit()

time.sleep(0.8)

instituto = inp("   Instituto: ")
if instituto in ["Salome", "Cmrio"]:
    print("   Você faz parte do sistema escolar")
else:
    print("   Você não pertence a esse instituto.")
    exit()

time.sleep(1)
print("   Professor entrou no sistema")
time.sleep(1)

while True:
    print()
    print("   Selecione o que você quer fazer:")
    time.sleep(0.5)
    print("   1 = Lançar Nota")
    print("   2 = Informações do sistema")
    print("   3 = Avisos aos Professores")
    time.sleep(0.5)

    selection = inp("   Número: ")

    if selection in ["1", "Lançar Nota"]:
        while True:
            print()

            while True:
                nomealuno = inp("   Nome do aluno: ")

                if nomealuno in alunos:
                    print("   Aluno cadastrado")
                    break
                else:
                    print("   Aluno não cadastrado. Tente novamente.")

            if nomealuno in notas_lancadas:
                print(f"   O aluno {nomealuno} já possui nota lançada.")
                print("   Escolha outro aluno.")
                time.sleep(1)
                continue

            while True:
                matricula = inp("   Matrícula do aluno: ")

                if matricula == alunos[nomealuno]:
                    print(f"   Matrícula confirmada para {nomealuno}")
                    break
                else:
                    print(f"   Matrícula inválida para {nomealuno}. Tente novamente.")

            while True:
                nota = inp(f"   Nota Bimestral do aluno {nomealuno}: ")

                try:
                    nota = float(nota)
                except:
                    print("   Digite apenas números.")
                    continue

                if nota > 10 or nota < 0:
                    print("   De 0 a 10, por favor.")
                    continue

                notas_lancadas[nomealuno] = nota

                print(f"   Nota {nota} na matéria de {materia} foi lançada ao sistema para {nomealuno}")
                time.sleep(1)
                break

    elif selection == "2":
        print()
        print("   Este sistema é apenas para aprendizado em aulas solo do Yank Carvalho.")
        print("   Se você testou, agradeço muito <3")
        time.sleep(4)

    elif selection == "3":
        print()
        print("   Nenhum aviso no momento")
        time.sleep(3)

    else:
        print("   Opção inválida")
        time.sleep(1)