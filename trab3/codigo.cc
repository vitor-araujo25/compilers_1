#include <string>
using namespace std;

struct Lista {
bool sublista;
string valorString;
Lista* valorSublista;
Lista* proximo;
};

Lista* geraLista() {
Lista *l0;
l0 = new Lista;
Lista *l1;
l1 = new Lista;
Lista *l2;
l2 = new Lista;
Lista *l3;
l3 = new Lista;
Lista *l4;
l4 = new Lista;
Lista *l5;
l5 = new Lista;
Lista *l6;
l6 = new Lista;
Lista *l7;
l7 = new Lista;

l0->sublista = false;
l0->valorString = "a";
l0->valorSublista = nullptr;
l0->proximo = l1;

l1->sublista = false;
l1->valorString = "B";
l1->valorSublista = nullptr;
l1->proximo = l5;

l2->sublista = false;
l2->valorString = "1";
l2->valorSublista = nullptr;
l2->proximo = l3;

l3->sublista = false;
l3->valorString = "3";
l3->valorSublista = nullptr;
l3->proximo = l4;

l4->sublista = false;
l4->valorString = "3";
l4->valorSublista = nullptr;
l4->proximo = nullptr;

l5->sublista = true;
l5->valorString = "";
l5->valorSublista = l2;
l5->proximo = l7;

l6->sublista = false;
l6->valorString = "i";
l6->valorSublista = nullptr;
l6->proximo = nullptr;

l7->sublista = true;
l7->valorString = "";
l7->valorSublista = l6;
l7->proximo = nullptr;

return l0;
};
