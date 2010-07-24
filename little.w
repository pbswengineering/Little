\documentclass[a4paper,11pt]{report}
\usepackage[italian]{babel}
\usepackage{url}
\usepackage{ucs}
\usepackage[utf8x]{inputenc} 
\usepackage[T1]{fontenc}
\usepackage{ae,aecompl}
\usepackage{eurosym}
\usepackage{fullpage}
\usepackage[dvips]{graphicx}
\usepackage[Bjornstrup]{fncychap}
\frenchspacing
\usepackage[dvips, bookmarks, colorlinks=true, linkcolor=blue, pdftitle={LITTLE} pdfauthor={Paolo Bernardi}]{hyperref}
\setlength{\parskip}{\baselineskip}
\setlength{\parindent}{0em}

\begin{document}

\title{\null \vspace{\stretch{1}}
  \Huge{LITTLE: interprete di un semplice linguaggio di programmazione
    imperativo}\\[\baselineskip]
  \Large{Esame di Laboratorio di Programmazione Avanzata\\
  A.A. 2007/08\\[\baselineskip]
  Corso di Laurea in Informatica\\Università degli Studi di
  Perugia}\\[\baselineskip]
  \includegraphics[width=.3\textwidth]{../pics/unipg.eps}\\[\baselineskip]
\vspace{\stretch{1}} \null}
\author{Paolo Bernardi}

\maketitle
\thispagestyle{empty}
\newpage

\tableofcontents

\chapter{Il problema}

Il progetto d'esame consiste nella creazione di un interprete per un
semplice linguaggio di programmazione imperativo mediante il C++. In
particolare tale linguaggio deve avere le seguenti caratteristiche:
\begin{itemize}
  \item le variabili sono soltanto di tipo intero;

  \item sono supportate le operazioni di addizione, sottrazione,
    moltiplicazione, divisione e modulo;

  \item devono essere presenti i costrutti di elaborazione
    sequenziale, condizionale (\verb|If|-\verb|Else|) e iterativa (\verb|While|);

  \item poiché alcuni dei costrutti menzionati al punto precedente
    richiedono delle condizioni booleane, queste devono essere
    esprimibili mediante prodotto logico, somma logica e negazione;
    inoltre devono essere presenti i principali operatori relazionali:
    uguale, diverso, maggiore, minore, maggiore o uguale, minore o
    uguale;

  \item deve essere possibile richiedere all'utente l'immissione del
    valore di una variabile da tastiera;

  \item deve essere possibile mostrare il valore di una variabile su
    schermo.
\end{itemize}

\chapter{Il linguaggio LITTLE}

\section{Definizione del linguaggio}

Sulla base dei requisiti richiesti ho dapprima definito un linguaggio
comforme agli stessi mediante la notazione EBNF:

\begin{table}[h]
\caption{La grammatica di LITTLE.}
\begin{center}
\begin{tabular}{|l|}
\hline
\\
PROGRAM \( \longrightarrow \) ``Program'' IDENTIFIER BLOCK . \\

BLOCK \( \longrightarrow \) ``Begin'' [ CONDITION | REPETITION | INPUT
| OUTPUT \\
\hspace*{4cm}| ASSIGNMENT ]* ``End'' . \\

INPUT \( \longrightarrow \) ``Input'' IDENTIFIER . \\

OUTPUT \( \longrightarrow \) ``Output'' IDENTIFIER . \\

REPETITION \( \longrightarrow \) ``While'' BLOCK . \\

CONDITIONAL \( \longrightarrow \) ``If'' RELATION BLOCK [ ``Else''
BLOCK ] . \\

RELATION \( \longrightarrow \) B\_EXPRESSION [ RELOP B\_EXPRESSION ]*
. \\

RELOP \( \longrightarrow \) ``=='' | ``<>'' | ``<'' | ``>'' | ``<='' | 
``>='' . \\

B\_EXPRESSION \( \longrightarrow \) EXPRESSION [ BOP EXPRESSION ]* . \\

BOP \( \longrightarrow \) ``\&'' | ``|'' .  \\

EXPRESSION \( \longrightarrow \) [ ADDOP ] TERM [ ADDOP TERM ]* . \\

ADDOP \( \longrightarrow \) ``+'' | ``-'' .  \\

TERM \( \longrightarrow \) FACTOR [ MULOP FACTOR ]* . \\

MULOP \( \longrightarrow \) ``*'' | ``/'' | ``\%'' . \\

FACTOR \( \longrightarrow \) ``('' RELATION ``)'' | ``!'' FACTOR | 
IDENTIFIER | NUMBER . \\

IDENTIFIER \( \longrightarrow \) LETTER [ LETTER | DIGIT | ``\_'' ]*
. \\

NUMBER \( \longrightarrow \) [ DIGIT ]+ . \\

LETTER \( \longrightarrow \) ``A'' .. ``Z'' | ``a'' .. ``z'' . \\

DIGIT \( \longrightarrow \) ``0'' .. ``9'' . \\\\
\hline
\end{tabular}
\end{center}
\end{table}

Come si evince dalla sua grammatica, LITTLE è un linguaggio il cui
stile riprende principalmente quello della famiglia di ALGOL; le
principali differenze sono negli operatori, più simili alla famiglia
del C.

È possibile assegnare il risultato di un'espressione booleana ad una
variabile; poiché le variabili sono soltanto di tipo intero, LITTLE
gestisce i valori di verità come il linguaggio C: lo 0 rappresenta il
falso e qualsiasi altro numero il vero. Pertanto gli operatori
booleani e relazionali restituiscono dei numeri interi.

Non è prevista alcuna dichiarazione per le variabili; queste vengono
create automaticamente quando gli viene assegnato un valore. Usare
una variabile che non è ancora stata creata costituisce un errore.

Dalla grammatica possiamo inoltre ricavare la suddivisione dei vari
operatori secondo la propria precedenza; nella tabella \ref{operatori}
sono riportate le classi di precedenza degli operatori, in ordine di
priorità decrescente dall'alto verso il basso:

\begin{table}[h]
\caption{Le classi di precedenza degli operatori.}
\label{operatori}
\begin{center}
\begin{tabular}{|c|}
\hline
\\\( ! \quad (\ ) \) \\\\
\hline
\\\( * \quad / \quad \% \) \\\\
\hline
\\\( + \quad - \) \\\\
\hline
\\\( \& \quad | \) \\\\
\hline
\\\( == \quad <> \quad < \quad > \quad <= \quad >= \) \\\\
\hline
\end{tabular}
\end{center}
\end{table}

L'operatore \verb|!| rappresenta la negazione logica, \verb|&| il
prodotto logico, \verb$|$ la somma logica, \verb|==| l'uguaglianza e
\verb|<>| il suo opposto. Tutti gli operatori binari sono associativi
a sinistra.

Il linguaggio è case insensitive sia rispetto alle parole chiave sia
rispetto ai nomi delle variabili.

Un'altra peculiarità di LITTLE è l'obbligo di racchiudere i blocchi
sequenziali tra \verb|Begin| e \verb|End| anche quando siano composti
da una singola istruzione.

Per quanto riguarda le espressioni booleane, LITTLE non usa la logica
corto circuito; tutti i termini degli operatori di somma e prodotto
logico sono elaborati a prescindere dal loro valore.

Infine, sebbene non presenti nella grammatica, LITTLE consente l'uso
di commenti su singola linea, riconoscibili perché preceduti dal
carattere \verb|#|.

\section{Alcuni esempi}

Di seguito riporto alcuni esempi di programmi LITTLE. I file hanno
l'estensione caratteristica del linguaggio, ``\verb|.lil|''.

@o factorial.lil
@{@_Program@_ factorial
# Calcola il fattoriale del numero
# richiesto in input all'utente.
@_Begin@_
    @_Input@_ n
    factorial = 1
    @_While@_ n > 1 @_Begin@_
        factorial = factorial * n
        n = n - 1
    @_End@_
    @_Output@_ factorial
@_End@_
@}

@o guess.lil
@{@_Program@_ guess_the_number
# Indovina il numero segreto!
@_Begin@_
    secret = 8
    guess = -1

    win = 1
    too_few = 0
    too_much = 0

    @_While@_ secret <> guess @_Begin@_
        @_Input@_ guess
        # Modo contorto per scrivere un'uguaglianza
        @_If@_ !(secret <> guess) @_Begin@_
            @_Output@_ win # Woohoo
        @_End@_ @_Else@_ @_Begin@_ 
            @_If@_ secret < guess @_Begin@_
                @_Output@_ too_much # Booo
            @_End@_ @_Else@_ @_Begin@_
                @_Output@_ too_few # Booo
            @_End@_ # If interno
        @_End@_ # If esterno
    @_End@_ # While
@_End@_ # Program
@}

@o prime.lil
@{@_Program@_ test_prime
# Controlla che il numero immesso dall'utente
# sia primo.
@_Begin@_
   @_Input@_ n
   c = 2
   is_prime = 1
   @_While@_ (c < n / 2) & is_prime @_Begin@_
      @_If@_ n % c == 0 @_Begin@_
	      is_prime = 0
      @_End@_
      c = c + 1
   @_End@_
   @_Output@_ is_prime
@_End@_
@}

@o gcd.lil
@{@_program@_ gcd
# Calcola l'MCD di due interi
@_begin@_
    @_input@_ a
    @_input@_ b
    @_while@_ a <> b @_begin@_
        @_if@_ a > b @_begin@_
            a = a - b
        @_end@_ @_else@_ @_begin@_
            b = b - a
        @_end@_
    @_end@_
    gcd = a
    @_output@_ gcd
@_end@_
@}

\chapter{L'interprete}

La creazione di compilatori e interpreti è una branca dell'informatica
che è stata studiata e formalizzata moltissimo, specialmente dopo
l'avvento di ALGOL 60 e l'introduzione delle grammatiche BNF per la
descrizione dei linguaggi di programmazione.

Per questo motivo ho scelto di attenermi ad una tecnica di
programmazione consolidata: il parsing top down a discesa
ricorsiva. Questa tecnica consente una traduzione più o meno automatica
delle equazioni grammaticali in codice eseguibile. Il codice
risultante consiste in una serie di funzioni, ciascuna
corrispondente al lato sinistro di una produzione, che richiamano le
funzioni corrispondenti alle sotto-produzioni presenti nel lato
destro.

Ho cercato di mantenere ridotte le dimensioni del codice sorgente, in
onore al nome del linguaggio. Per questo motivo ho evitato una
separazione netta tra l'analizzatore lessicale ed il parser; ho anche
tralasciato l'uso di rappresentazioni intermedie dei programmi da
interpretare (Abstract Syntax Tree, bytecode\ldots{}).

Le librerie necessarie sono le seguenti; ho preferito importare tutti
i nomi del namespace \verb|std| in quello locale:

@d Librerie utilizzate
@{#include <cstdlib>
#include <cctype>
#include <fstream>
#include <iostream>
#include <map>

using namespace std;
@}

In diversi punti del programma ho ritenuto opportuno segnalare delle
condizioni di errore all'utente mediante le seguenti procedure.
L'interprete interrompe automaticamente la sua esecuzione dopo un
errore:

@d Procedure per la segnalazione di errori
@{void abort(string error_message) {
        cerr << endl;
        cerr << "Error: " << error_message << "." << endl;
        cerr << "[row " << row << "]" << endl;
        exit(1);
}

void expected(string expected_message) {
        cerr << expected_message << " expected." << endl;
        cerr << "[row " << row << "]" << endl;
        exit(1);
}
@| abort expexted @}

Ogni messaggio d'errore è seguito dall'indicazione del numero di riga
dove è stato riscontrato.

\section{Scansione a livello di singolo carattere}

Ora passiamo alla scansione del file contenente il programma da
interpretare: il primo passo è quello di leggerlo carattere per
carattere. Questo è il compito della procedura \verb|next_char|, che
pone il carattere letto nella variabile globale \verb|lookahead|.

In realtà il comportamento di \verb|next_char| è un po' più complesso:
per necessità dettate dalla mia decisione di non usare AST o similari,
all'atto dell'esecuzione di costrutti iterativi quali il \verb|While|
è necessario che l'interprete interrompa la lettura dei caratteri dal
file di input e continui a eseguire il frammento di programma del
blocco \verb|While| fino a quando la sua condizione rimane vera. Al
fine di ottenere questo risultato ho modificato \verb|next_char|
rendendola in grado di leggere i caratteri sia dal file di input
(\verb|input_stream|), sia da un buffer in memoria
(\verb|reproduce_buffer|), a seconda del valore della variabile
booleana globale \verb|reproducing|.

Inoltre, \verb|next_char| può salvare su un'altro buffer in memoria
(\verb|record_buffer|) i caratteri che legge da qualsiasi sorgente. Il
salvataggio dei caratteri è controllato dal flag globale
\verb|recording|. Seguono le variabili globali usate da
\verb|next_char| e la procedura stessa:

@d Variabili per la procedura next\_char
@{char lookahead;

ifstream *input_stream;
int row = 1;

bool recording = false;
string record_buffer = "";

bool reproducing = false;
string reproduce_buffer = "";
@| input_stream row recording record_buffer reproducing reproduce_buffer @}

@d Procedura next\_char
@{void next_char() {
        if (reproducing) {
                lookahead = reproduce_buffer[0];
                reproduce_buffer.erase(0, 1);
        } else {
                lookahead = static_cast<char>(input_stream->get());
                if (lookahead == '\n') ++row;
        }
        if (recording) record_buffer += lookahead;
        @<Codice per ignorare...@>
}
@| next_char @}

\verb|next_char| tiene aggiornato il contatore della riga corrente,
utilizzato nei messaggi di errore.

Come detto nella definizione del linguaggio, LITTLE supporta anche dei
commenti su singola linea delimitati dal carattere \verb|#|. Per far
si che \verb|next_char| ignori tutti i caratteri a partire da \verb|#|
fino alla lina successiva basta aggiungervi il seguente codice:

@d Codice per ignorare i caratteri dei commenti
@{if (lookahead == '#') while (lookahead != '\n') next_char();
@}

Durante la scansione carattere per carattere è necessario ignorare gli
spazi bianchi ed altri caratteri simili. Per questo motivo ho definito
queste due procedure:

@d Gestione degli spazi e caratteri "vuoti" in genere
@{void skip_white() {
        while (isspace(lookahead) && (lookahead != '\n')) next_char();
}

void skip_white_newline() {
        while (isspace(lookahead)) next_char();
}
@| skip_white skip_white_newline @}

La mentre \verb|skip_white_newline| salta tutti i caratteri simil
spazio, \verb|skip_white| esclude da questi il terminatore di linea.

Infine, ci sono dei punti in cui l'interprete è in grado di sapere in
anticipo qual'è il carattere che dovrebbe leggere: ad esempio, in
un'istruzione di assegnamento, la variabile cui viene assegnato un
valore dovrebbe essere seguita dal carattere \verb|=|; se ciò non
accade è necessario segnalare l'errore. La procedura che segue serve
proprio a trattare casi come questo:

@d Lettura di un carattere atteso
@{void match(char to_match) {
        if (to_match == lookahead) {
                next_char();
                skip_white();
        } else expected(string("\"") + to_match + "\"");
}
@| match @}

\verb|match| effettua il confronto tra il carattere atteso e
\verb|lookahead|: se sono uguali, legge il successivo carattere
significativo (salta gli spazi), altrimenti termina l'interprete con
un messaggio d'errore.

Conseguentemente alla lettura dei caratteri c'è la necessità di
suddividerli in categorie. Per questo scopo la libreria \verb|ctype|
fornisce già una serie di utili funzioni come \verb|isalnum| per
riconoscere i caratteri alfanumerici, \verb|isalpha| per le lettere
dell'alfabeto e \verb|isdigit| per le cifre numeriche; anche la
funzione \verb|isspace|, usata nelle procedure per saltare gli spazi
bianchi, fa parte di questa libreria.

Poiché le funzioni viste sopra coprono soltanto una parte delle
necessità di questo analizzatore lessicale, ne ho definite altre in
grado di riconoscere rispettivamente gli operatori additivi,
moltiplicativi e booleani; in questi ultimi non è compresa la
negazione, indicata con il simbolo \verb|!|, che verrà gestita a parte
in quanto operatore unario:

@d Riconoscimento degli operatori binari lunghi un solo carattere
@{bool isaddop(char c) {
        return ((c == '+') || (c == '-'));
}

bool ismulop(char c) {
        return ((c == '*') || (c == '/')) || (c == '%');
}

bool isbop(char c) {
        return ((c == '|') || (c == '&'));
}
@| isaddop ismulop isbop @}

Alcuni operatori relazionali sono lunghi due caratteri, pertanto ho
incluso una funzione per riconoscere se il carattere lookahead
corrente è l'inizio di uno di questi. Ho anche ritenuto opportuno
inserire una funzione che riconoscesse se il lookahead corrente è un
qualsiasi operatore lungo un carattere o l'inizio di un'operatore
lungo due caratteri:

@D Riconoscimento del primo carattere di un operatore
@{bool isrop(char c) {
        return ((c == '=') ||
                (c == '<') ||
                (c == '>'));
}

bool isop(char c) {
        return ((c == '+') ||
                (c == '-') ||
                (c == '*') ||
                (c == '/') ||
                (c == '%') ||
                (c == '(') ||
                (c == ')') ||
                (c == '<') ||
                (c == '>') ||
                (c == '|') ||
                (c == '&') ||
                (c == '!') ||
                (c == '<') ||
                (c == '>') ||
                (c == '='));
}
@| isrop isop @}

\section{Scansione a livello di token}

Nonostante sia possibile fare già moltissimo con la scansione dei
programmi da interpretare a livello di singolo carattere, ci sono dei
casi in cui è necessario invece fornire al parser degli interi token:
ad esempio, leggendo un codice sorgente carattere per carattere, il
parser potrebbe distinguere facilmente un numero da una variabile, ma
non una variabile da un identificatore in quanto entrambi sono
stringhe alfanumeriche; inoltre, un analizzatore lessicale che
fornisce di volta in volta degli interi token è comodo in molte
situazioni.

Per rappresentare i vari tipi di token previsti da LITTLE ho adottato
una struttura dati \verb|enum|, così da poter usare in seguito
costrutti come lo \verb|switch|:

@D Enum dei vari tipi di token
@{enum symbol { NONEsym,
              PROGRAMsym,
              IFsym, 
              ELSEsym, 
              BEGINsym,
              ENDsym, 
              WHILEsym,
              IDENTsym, 
              NUMBERsym, 
              OPERATORsym,
              INPUTsym,
              OUTPUTsym };
@| symbol @}

Ovviamente \verb|IDENT| sta per identifier, ovvero un nome di
variabile. Anche le procedure di input/output hanno i propri tipi di
token.

Così come l'ultimo carattere letto dal sorgente da interpretare è
memorizzato in una variabile globale, anche il tipo e l'effettivo
valore dell'ultimo token letto hanno le proprie variabili. Per quanto
riguarda i valori, poiché token di tipo \verb|NUMBERsym| sono
effettivamente numeri interi mentre gli altri sono delle stringhe, ho
previsto due variabili, una per ciascun caso.

@d Variabili dell'ultimo token letto
@{symbol token;
string value;
int num_value;
@| token value num_value @}

Per poter associare le stringhe che rappresentano le parole chiave ai
simboli corrispondenti, ho utilizzato una \verb|map|:

@d Map delle parole chiave
@{map<string, symbol> keywords;
@| keywords @}

Tale \verb|map| viene popolata subito dopo l'avvio del programma in
questo modo:

@d Popolamento della map delle parole chiave
@{keywords["PROGRAM"] = PROGRAMsym;
keywords["IF"] = IFsym;
keywords["ELSE"] = ELSEsym;
keywords["BEGIN"] = BEGINsym;
keywords["END"] = ENDsym;
keywords["WHILE"] = WHILEsym;
keywords["INPUT"] = INPUTsym;
keywords["OUTPUT"] = OUTPUTsym;
@}

Per effettuare la corrispondenza tra una stringa e la parola chiave
che rappresenta ho definito questa semplice funzione:
\verb|get_keyword| restituisce il simbolo corrispondente alla parola
chiave o \verb|NONEsym| se l'argomento non è riconosciuto:

@d Riconoscimento delle parole chiave
@{symbol get_keyword(string name) {
        map<string, symbol>::iterator i = keywords.find(name);
        return i != keywords.end() ? i->second : NONEsym;
}
@|get_keyword @}

Veniamo ora alle procedure che leggono di volta in volta il token
successivo del programma da interpretare. Poiché i token sono
rappresentabili da semplici espressioni regolari il codice per
riconoscerli è di fatto l'implementazione di (banali) automi a stati
finiti. Tale codice opera secondo il seguente schema: controlla che
\verb|lookahead| sia l'inizio del tipo di token corrispondente ed
eventualmente continua a leggere caratteri fino a quando non ne
incontra uno che non gli appartiene (stato terminale).

Seguono le procedure per leggere una parola chiave o identificatore,
un numero intero e un operatore:

@D Riconoscimento di specifici tipi di token
@{void get_name() {
        value = "";
        if (!isalpha(lookahead)) expected("Name");
        while (isalnum(lookahead) || (lookahead == '_')) {
                value += (char)toupper(lookahead);
                next_char();
        }
        @< Distinzione tra parole chiave e identificatori @>
        skip_white();
}

void get_number() {
        value = "";
        num_value = 0;
        if (!isdigit(lookahead)) expected("Integer");
        while (isdigit(lookahead)) {
                value += lookahead;
                @< Salvataggio del valore numerico del token @>
                next_char();
        }
        token = NUMBERsym;
        skip_white();
}

void get_operator() {
        value = "";
        if (!isop(lookahead)) expected("Operator");
        while (isop(lookahead)) {
                value += lookahead;
                next_char();
        }
        token = OPERATORsym;
        skip_white();
}
@|get_name get_number get_operator @}

La procedura \verb|get_name| usa la funzione \verb|toupper| per
rendere parole chiave e identificatori case insensitive.

Inoltre \verb|get_name| ingloba l'ambiguità dovuta al fatto che le
parole chiave e gli identificatori condividono la stessa espressione
regolare; pertanto il discernimento tra i due viene effettuato
soltanto dopo aver letto l'intero token, mediante la funzione per il
riconoscimento delle parole chiave definita sopra:

@d Distinzione tra parole chiave e identificatori
@{symbol k = get_keyword(value);
if (k == NONEsym) token = IDENTsym;
else token = k;
@}

La procedura \verb|get_number| salva il valore del token corrente sia
come stringa sia, per comodità, come numero:

@d Salvataggio del valore numerico del token
@{num_value = num_value * 10 + lookahead - '0';
@}

Infine ho creato una procedura per la scansione di un token generico:

@d Scansione di un token qualsiasi
@{void scan() {
        skip_white_newline();
        if (isalpha(lookahead)) get_name();
        else if (isdigit(lookahead)) get_number();
        else if (isop(lookahead)) get_operator();
        else abort("Unexpected token: '" + value + "'.");
        skip_white();
}
@|scan @}

\section{Il parser}

\subsection{Gestione delle variabili}

Prima di passare al parsing vero e proprio vediamo la gestione delle
variabili. LITTLE consente l'uso di variabili intere rappresantate da
identificatori alfanumerici e che non necessitano di dichiarazione. Ho
scelto di memorizzare le variabili in una \verb|map| che fa
corrispondere il loro nome al loro valore:

@d Map delle variabili
@{map<string, int> variables;
@|variables @}

La creazione o la modifica di una variabile consiste semplicemente in
un assegnazione a questa \verb|map|. La lettura di una variabile
invece è gestita da una funzione che si occupa anche di controllare
che la variabile esista o meno; in quest'ultimo caso interrompe
l'esecuzione del programma con un opportuno messaggio di errore:

@d Lettura del valore di una variabile
@{int get_var(string name) {
        map<string, int>::iterator i = variables.find(name);
        if (i == variables.end()) abort(name + " not found.");
        return i->second;
}
@|get_var @}

\subsection{Implementazione delle produzioni}

Vediamo ora l'implementazione delle procedure per il parsing a discesa
ricorsiva; la descrizione seguirà fedelmente l'approccio top-down,
partendo dall'implementazione della produzione di livello più alto:
\verb|PROGRAM|. La procedura seguente si occupa innanzi tutto di far
iniziare la lettura dei caratteri dal sorgente da interpretare, quindi
legge la parola chiave \verb|Program| seguita dal nome del programma e
richiama la procedura per la gestione del blocco di istruzioni
principale.

@d Implementazione della produzione PROGRAM
@{void program() {
        skip_white_newline();
        next_char();
        get_name();
        if (token != PROGRAMsym) expected("Program");
        get_name();
        if (token != IDENTsym) abort("Incorrect program name");
        cout << "Running " << value << endl << endl;
        block();
        cout << endl << "Bye bye... Thank you for using me!" << endl;
}
@|program @}

Seguendo il flusso delle chiamate ricorsive, passiamo alla procedura
\verb|block|, l'implementazione della produzione omonima. Questa
controlla innanzitutto che ci sia il \verb|Begin| che contraddistingue
l'inizio del blocco e prosegue nella sua elaborazione fino ad
incontrare il rispettivo \verb|End|. La gestione delle istruzioni
presenti all'interno del blocco è semplice: si legge un token e viene
richiamata la procedura corrispondente alla produzione di cui il token
letto rappresenta l'inizio.

@d Implementazione della produzione BLOCK
@{void block() {
        skip_white_newline();
        get_name();
        if (token != BEGINsym) expected("Begin");
        bool ifsym;
        while (token != ENDsym)  {
                ifsym = false;
                switch (token) {
                case BEGINsym: break;
                case IFsym: conditional(); ifsym = true; break;
                case WHILEsym: repetition(); break;
                case OUTPUTsym: output(); break;
                case INPUTsym: input(); break;
                case IDENTsym: assignment(); break;
                default: abort("\"" + value + "\": undefined symbol.");
                }
                if(!ifsym) scan();
        }
}
@| block @}

Il costrutto condizionale \verb|If| è gestito in modo particolare: per
ragioni che verranno chiarite in seguito, a differenza delle altre
procedure, \verb|conditional| legge già il token successivo
all'\verb|End| del suo blocco di istruzioni, pertanto questo caso
particolare viene gestito con la variabile booleana \verb|ifsym|.

Poiché le possibili produzioni contenute in un blocco iniziano
necessariamente con una parola chiave (comprese \verb|INPUT| e
\verb|OUTPUT|) o con un identificatore di variabile (nel caso
dell'assegnamento), \verb|block| effettua la lettura del token da
controllare con la procedura \verb|get_name|: in questo modo
l'interprete segnalerà l'errore qualora un'istruzione inizi con un
operatore o con un numero intero.

Le istruzioni più semplici contenute in un blocco sono sicuramente
\verb|Input| e \verb|Output|, poiché il loro compito è soltanto quello
di leggere o stampare il valore di una variabile. La loro
implementazione è la seguente:

@d Implementazione delle produzioni INPUT e OUTPUT
@{void input() {
        get_name();
        cout << "INPUT(" << value << "): ";
        int n;
        cin >> n;
        variables[value] = n;
}

void output() {
        get_name();
        cout << value << " -> " << get_var(value) << endl;
}
@| input output @}

Come accadrà anche per le procedure che gestiscono le altre produzioni
interne ai blocchi, \verb|input| e \verb|output| non devono leggere la
propria parola chiave perché questa è già stata letta dalla procedura
\verb|block| ed utilizzata per il loro riconoscimento. Per questa
ragione queste due procedure leggono direttamente il nome della
variabile che dovranno gestire ed effettuano su di essa le azioni
opportune.

Vediamo ora la procedura che gestisce l'assegnamento; il codice è
banale perché non fa altro che assegnare il valore del lato destro
alla variabile il cui token corrispondente è già stato letto dalla
procedura \verb|block|; il valore del lato destro è ovviamente il
risultato di un'espressione. Poiché LITTLE gestisce i valori booleani
come interi la distinzione tra espressioni booleane ed aritmetiche
perde di significato ed è possibile assegnare ad una variabile il
risultato di un'espressione contenente qualsiasi operatore. Come si
può notare dalla grammatica, la produzione più generica per indicare
un'espressione è \verb|RELATION|, pertanto qui viene usata la
procedura corrispondente. Ovviamente viene controllato se tra il lato
sinistro e quello destro dell'assegnamento è presente l'operatore
\verb|=|.

@D Implementazione della produzione ASSIGNMENT
@{void assignment() {
        string var = value;
        match('=');
        variables[var] = relation();
}
@| assignment @}

\subsection{Espressioni aritmetiche e booleane}

Seguiamo ora la serie di chiamate ricorsive che serviranno ad ottenere
il valore di un'espressione. Come visto sopra, tutto parte da
\verb|relation|:

@d Implementazione della produzione RELATION
@{int relation() {
        int result = b_expression();
        while (isrop(lookahead)) {
                get_operator();
                if (value == "<") result = result < b_expression();
                else if (value == ">") result = result > b_expression();
                else if (value == "<=") result = result <= b_expression();
                else if (value == ">=") result = result >= b_expression();
                else if (value == "==") result = result == b_expression();
                else if (value == "<>") result = result != b_expression();
        }
        return result;
}
@| relation @}

Anche in questo caso lo schema ricalca fedelmente la struttura della
grammatica, ma a differenza della procedura \verb|assignment| tra il
lato sinistro e quello destro dell'espressione possono esserci diversi
operatori, ciascuno con il proprio significato.

I valori che la procedura \verb|relation| confronta sono a loro volta
ottenuti da espressioni booleane; queste sono gestite dalla procedura
\verb|b_expression|:

@d Implementazione della produzione B\_EXPRESSION
@{int b_expression() {
        int result = expression();
        while (isbop(lookahead)) {
                get_operator();                
                if (value == "|") result = expression() || result;
                else if (value == "&") result = expression() && result;
        }
        return result;
}
@| b_expression @}

Durante il calcolo del risultato dell'espressione la chiamata alla
procedura \verb|expression| è effettuata al lato sinistro degli
operatori \verb?||? e \verb|&&|. Questo è possibile perché quelle
operazioni sono commutative ed è indispensabile perché altrimenti la
logica corto circuito del C++ potrebbe impedire la chiamata di
\verb|expression|.

La procedura \verb|expression| serve per valutare espressioni
aritmetiche con addizioni e sottrazioni. La sua unica particolarità
sta nella gestione dei numeri negativi: se un'espressione è preceduta
dall'operatore \verb|-| il risultato è la sua negazione; questo
effetto viene ottenuto sottraendo a 0 il valore dell'espressione. Il
codice è stato generalizzato per permettere anche l'uso del \verb|+|
prefisso, anche se in questo caso il risultato dell'espressione
ovviamente non cambia.

@d Implementazione della produzione EXPRESSION
@{int expression() {
        int result;
        if (isaddop(lookahead)) result = 0;
        else result = term();
        while (isaddop(lookahead)) {
                get_operator();
                if (value == "+") result += term();
                else if (value == "-") result -= term();
        }
        return result;
}
@| expression @}

A sua volta la procedura \verb|expression| richiama \verb|term|, che
si occupa di gestire le operazioni di divisione, moltiplicazione e
modulo. La sua struttura è in linea con quanto visto fino ad ora,
senza nessuna sorpresa:

@d Implementazione della produzione TERM
@{int term() {
        int result = factor();
        while (ismulop(lookahead)) {
                get_operator();
                if (value == "*") result *= factor();
                else if (value == "/") result /= factor();
                else if (value == "%") result %= factor();
        }
        return result;
}
@| term @}

L'ultima procedura da definire per la gestione delle espressioni
aritmetico-booleane è \verb|factor|. All'interno di un'espressione
(produzione \verb|RELATION|) il suo ruolo è triplice: 

\begin{enumerate}
\item gestisce intere relazioni tra parentesi, permettendo di
  specificare con esattezza la precedenza delle operazioni;

\item consente l'uso della negazione logica;

\item gestisce le costanti di tipo numerico o le variabili che possono
  apparire in un'espressione.

\end{enumerate}

@d Implementazione della produzione FACTOR
@{int factor() {
        int result;
        if (lookahead == '(') {
                match('(');
                result = relation();
                match(')');
        } else if (lookahead == '!') {
                match('!');
                return !factor();
        } else {
                scan();
                if (token == NUMBERsym) result = num_value;
                else result = get_var(value);
        }
        return result;
}
@| factor @}

\subsection{Costrutti condizionali e iterativi}

A questo punto sono rimaste da implementare le produzioni
\verb|CONDITIONAL| e \verb|REPETITION|. Queste presentano delle
peculiarità dovute alla scelta di non usare Abstract Syntax Tree o
strutture dati similari.

Vediamo il costrutto \verb|If|-\verb|Then|-\verb|Else|. Il suo
funzionamento è semplice: si valuta il valore di verità della
condizione ad esso associata, mediante la funzione \verb|relation|
definita in precedenza; se il suo valore è vero si esegue il ramo
\verb|If|, altrimenti, qualora sia presente, il ramo \verb|Else|.

Per eseguire le istruzioni dei suoi sotto-blocchi viene utilizzata la
procedura \verb|block|. Per saltare l'esecuzione del blocco \verb|If|
in caso di condizione falsa o dell'eventuale blocco \verb|Else| in
caso di condizione vera ho utilizzato una procedura che descriverò tra
poco: \verb|avoid_internal_blocks|.

Per determinare la presenza o meno della parola chiave \verb|Else| è
necessario leggere un ulteriore token che potenzialmente potrebbe non
appartenere alla produzione \verb|CONDITIONAL|. Questo comportamento,
unico della procedura \verb|conditional|, è alla base della sua
particolare gestione all'interno di \verb|block|. Per uniformità,
anche qualora il ramo \verb|Else| sia presente, al termine della sua
esecuzione viene letto un ulteriore token che sarà sicuramente di
competenza di un'altra produzione.

@d Implementazione della produzione CONDITIONAL
@{void conditional() {
        if (token != IFsym) expected("If");
        else {
                int truth = relation();
                if (truth) block();
                else avoid_internal_blocks();
                skip_white_newline();
                get_name();
                if (token == ELSEsym) {
                        if (truth) avoid_internal_blocks();
                        else block();
                        skip_white_newline();
                        get_name();
                }
        }
}
@| conditional @}

Come detto sopra, per gestire la non esecuzione di un blocco facendo
nel contempo avanzare la lettura dei caratteri del sorgente viene
usata la procedura \verb|avoid_internal_blocks|. Questa non fa altro
che avanzare di token in token fino a trovare l'\verb|End|
corrispondente al \verb|Begin| iniziale tenendo il conto dei blocchi
interni ed ignorandoli.

@d Lettura del sorgente senza esecuzione
@{void avoid_internal_blocks() {
        int count = -1;
        while ((token != ENDsym) || (count > 0)) {
                if (token == BEGINsym) ++count;
                else if (token == ENDsym) --count;
                skip_white_newline();
                scan();
        }
}
@| avoid_internal_blocks @}

Passiamo ora al costrutto iterativo, il \verb|While|.
L'infrastruttura per registrare i caratteri letti su buffer e
rileggerli in seguito è stata introdotta proprio per la corretta
esecuzione delle iterazioni, che richiederebbero altrimenti una serie
di spostamenti all'indietro (seek) nel file sorgente. In effetti la
gestione del \verb|While| è divisa in due parti: una prima procedura
che legge e salva tutti i caratteri di cui è composto il costrutto,
esclusa la parola chiave \verb|While| iniziale, ed una seconda
procedura che esegue quanto registrato.

Vediamo la prima procedura: dopo aver attivato la registrazione dei
caratteri letti su buffer, \verb|repetition| legge e valuta la
relazione booleana che determina l'esecuzione delle iterazioni, poi
legge tutto il blocco sottostante al \verb|While|, senza eseguirne le
istruzioni; infine la registrazione viene interrotta e, sulla base
della condizione booleana, viene eventualmente eseguito il codice
registrato.

@d Implementazione della produzione REPETITION
@{void repetition() {
        if (token != WHILEsym) expected("While");
        else {
                record_buffer = "";
                recording = true;
                record_buffer = lookahead + record_buffer;
                int truth = relation();
                avoid_internal_blocks();
                recording = false;
                if (truth) repetition_exec(record_buffer);
        }
}
@| repetition @}

Un'osservazione importante: il buffer che contiene i caratteri da
riprodurre al posto di quelli letti dal file sorgente potrebbe già
contenere i caratteri di altri costrutti \verb|While| esterni a quello
corrente.

Inoltre, poiché \verb|lookahead| è già stato letto, viene inserito a
mano nel buffer dei caratteri registrati.

La procedura per eseguire effettivamente l'iterazione è riportata di
seguito:

@d Procedura per l'esecuzione dell'iterazione
@{void repetition_exec(string saved) {
        int truth = 1;
        while (truth) {
                string old_buffer = reproduce_buffer;
                reproduce_buffer = saved;
                reproducing = true;
                next_char();
                truth = relation();
                if (truth) block();
                else avoid_internal_blocks();
                if (old_buffer == "") reproducing = false;
                reproduce_buffer = old_buffer;
        }
}
@| repetition_exec @}

Il parametro \verb|saved| è un'insieme di caratteri consecutivi del
sorgente da interpretare, dalla condizione del \verb|While| compresa
fino all'\verb|End| del suo blocco, così come registrato dalla
procedura \verb|repetition|. Questo parametro viene usato per
sovrascrivere il ``buffer di riproduzione'', che viene comunque
salvato e ripristinato alla fine, qualora contenga il codice di altri
\verb|While| esterni a quello corrente la cui esecuzione era stata
sospesa.

Ovviamente, se la condizione del \verb|While| è vera
\verb|repetition_exec| esegue il codice del blocco corrispondente fino
a quando non diventa falsa, altrimenti salta fino alla fine del blocco
senza eseguire nulla e termina.

\section{Ultimi ritocchi}

A questo punto rimane soltanto la funzione \verb|main|. La sua prima
operazione è l'apertura del file passatogli come argomento della riga
di comando; in caso di errore o di mancato passaggio di questo
argomento da parte dell'utente viene mostrato un opportuno messaggio
di errore:

@d Apertura del file con il codice da interpretare
@{if (argc == 2) {
        input_stream = new ifstream();
        input_stream->open(argv[1]);
        if (input_stream->fail()) {
                delete input_stream;
                abort("Unable to open input file.");
        }
} else abort("You must specify the input file.");
@}

Una volta aperto il file con il codice sorgente da eseguire viene
richiamata la procedura \verb|program| che avvia il processo di
parsing a discesa ricorsiva. Terminata l'esecuzione, il file viene
chiuso.

@d Programma principale
@{int main(int argc, char *argv[]) {
        @< Apertura del file... @>
        @< Popolamento della map delle parole chiave @>

        program();

        input_stream->close();
        delete input_stream;
}
@| main @}

Ora possiamo assemblare i vari pezzi di codice per ottenere
l'interprete completo:

@O little.cpp -d
@{@< Librerie utilizzate @>
@< Enum dei vari tipi di token @>
@< Variabili per la procedura next\_char @>
@< Variabili dell'ultimo token letto @>
@< Map delle parole chiave @>
@< Map delle variabili @>
@< Procedure per la segnalazione di errori @>
@< Procedura next\_char @>
@< Gestione degli spazi... @>
@< Lettura di un carattere atteso @>
@< Riconoscimento degli operatori binari... @>
@< Riconoscimento del primo carattere... @>
@< Riconoscimento delle parole chiave @>
@< Riconoscimento di specifici tipi di token @>
@< Scansione di un token qualsiasi @>
@< Lettura del valore di una variabile @>
int relation();
@< Implementazione della produzione FACTOR @>
@< Implementazione della produzione TERM @>
@< Implementazione della produzione EXPRESSION @>
@< Implementazione della produzione B\_EXPRESSION @>
@< Implementazione della produzione RELATION @>
@< Implementazione della produzione ASSIGNMENT @>
@< Implementazione delle produzioni INPUT e OUTPUT @>
@< Lettura del sorgente senza esecuzione @>
void block();
@< Implementazione della produzione CONDITIONAL @>
@< Procedura per l'esecuzione dell'iterazione @>
@< Implementazione della produzione REPETITION @>
@< Implementazione della produzione BLOCK @>
@< Implementazione della produzione PROGRAM @>
@< Programma principale @>
@}

Sono presenti delle dichiarazioni anticipate di alcune funzioni per
evitare errori di compilazione dovuto alla mutua ricorsione.

\twocolumn
\chapter{Indice degli identificatori}

@u

\end{document}

% That's all, folks!
