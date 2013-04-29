fprintf('+------------------------------------------------------------------------+\n');
fprintf('|                         INTELIG�NCIA ARTIFICIAL                        |\n');
fprintf('|            Problema do Caixeiro Viajante sob a �tica dos AGs           |\n');
fprintf('|                         (Prof. Maur�lio J. In�cio)                     |\n');
fprintf('|                     Acad�mico: Felipe T�lio de Castro                  |\n');
fprintf('|                                  FACIT                                 |\n');
fprintf('+------------------------------------------------------------------------+\n');


%defini��o de par�metros inciais
fprintf('| Constru��o dos par�metros iniciais | \n');
TamPopulacao = input('Defina o tamanho da popula��o: \n'); %quantidade de individuos a serem criados
NumGeracoes = input('Defina o n�mero de gera��es: \n');
TaxaCruzamento = input('Defina a taxa de cruzamento: \n');
TaxaMutacao = input('Defina a taxa de muta��o: \n');

fprintf('\n\nIniciando busca pelo resultado... \n\n');

%abertura do arquivo que contem a matriz de distancias das cidades
Matriz_Arq = load('distancias.txt');

%descobrir o tamanho da matriz
TamMatriz = length(Matriz_Arq);

matriz_individuo = ones(TamPopulacao, TamMatriz); %matriz de individuos
individuo = (1:TamMatriz); %vetor de individuos usado para absorver os numeros rand�micos

% Gera��o dos estados iniciais
for i = 1 : TamPopulacao
    for j = 1 : TamMatriz
       individuo = randperm(TamMatriz); % n�mero aleat�rio
    end
    matriz_individuo(i,:) = individuo(1,:);
end

ger = 1;

vfitness = (1:TamPopulacao);
%xfitness = (1:NumGeracoes);
%xindividuo = (1:TamMatriz);
%xfuncaoObj = (1:NumGeracoes);
%vfuncaoObj = (1:TamPopulacao);
%valorFO = (1:TamMatriz);
%fprintf('Busca em: 10%\n\n');

ciclo = NumGeracoes/100;
cont = 0;
perc = 10;

%la�o que far� as itera��es acontecerem
while (ger < NumGeracoes)
    
    cont = cont + 1;
    if (cont == ciclo)
        perc = perc + 10;
        fprintf('\nBusca em: %i', perc); fprintf(' por cento\n');
        fprintf('Gera��o: %i\n', ger);
        ciclo = ciclo + ciclo;
    end
    
    % Avalia��o dos estados (fitness)
    for i = 1 : TamPopulacao
        for j = 1 : TamMatriz-1
            x = matriz_individuo(i,j);
            y = matriz_individuo(i,j+1);
            valorFO(j) = Matriz_Arq(x,y);
        end
        somafuncaoObj = sum(valorFO);
        vfuncaoObj(i) = somafuncaoObj; 
        vfitness(i) = 1 ./ (somafuncaoObj + 1e-6);
    end
    
    vMediafitness(ger) = mean(vfitness);
    
    [val idc] = max(vfitness); % valor e �ndice da fitness do melhor estado
    xindividuo(ger,:) = matriz_individuo(idc,:); % melhor individuo da gera��o
    xfitness(ger)= vfitness(idc); % fitness do melhor indiv�duo
    xfuncaoObj(ger) = vfuncaoObj(idc);
    
    
    % Guarda o melhor estado da �poca anterior (elistimo)
    if (ger > 1)
        if (xfitness(ger) < xfitness(ger-1))
            xindividuo(ger,:) = xindividuo(ger-1,:);
            xfitness(ger) = xfitness(ger-1);
            xfuncaoObj(ger) = xfuncaoObj(ger-1);
        end
    end

    %matrizSelecionados = zeros(TamPopulacao, TamMatriz); %matriz que receber� os novos individuos selecionados pelo m�todo da roleta
    matrizSelecionados(1,:) = xindividuo(ger,:);
    
    % Sele��o dos melhores estados (m�todo da roleta)
    somafitness = sum(vfitness); %somat�rio da fitness dos individuos
    for i = 2 : TamPopulacao
        numrnd = round(rand * somafitness); % n�mero aleat�rio entre 0 e o valor de somafitness
        acumulo = 0; % valor da fitness acumulada
        for j = 1 : TamPopulacao
            acumulo = acumulo + vfitness(j); 
            if (acumulo >= numrnd)
                matrizSelecionados(i,:) = matriz_individuo(j,:); % preenche novo conjunto de estados com os melhores estados
                break;
            end
        end
    end
        
    
    matrizFilhos = ones(TamPopulacao, TamMatriz);
    c = 1;
    
    % Cruzamento (m�todo OBX)
    while (c < TamPopulacao)
    %for c = 1 : TamPopulacao-1
        indicepai1 = 0;
        indicepai2 = 0;
        while ((indicepai1 == indicepai2)||(indicepai1 == 0) || (indicepai2 == 0))
            indicepai1 = round(rand * TamPopulacao);
            indicepai2 = round(rand * TamPopulacao);
        end
        probcruzamento = rand;
        if (probcruzamento <= TaxaCruzamento)
          n1 = 0;
          n2 = 0;
          n3 = 0;
          while((n1 == n2) || (n1 == n3) || (n2 == n3)|| (n1 == 0) || (n2 == 0) || (n3 == 0))
              n1 = round(rand * TamMatriz);
              n2 = round(rand * TamMatriz);
              n3 = round(rand * TamMatriz);
          end
              
          aux1 = matrizSelecionados(indicepai1,n1);
          matrizSelecionados(indicepai1,n1) = matrizSelecionados(indicepai1,n2);
          matrizSelecionados(indicepai1,n2) = matrizSelecionados(indicepai1,n3);
          matrizSelecionados(indicepai1,n3) = aux1;
          
          aux2 = matrizSelecionados(indicepai2,n1);
          matrizSelecionados(indicepai2,n1) = matrizSelecionados(indicepai2,n2);
          matrizSelecionados(indicepai2,n2) = matrizSelecionados(indicepai2,n3);
          matrizSelecionados(indicepai2,n3) = aux2;
          
          matrizFilhos(c,:) = matrizSelecionados(indicepai1,:);
          matrizFilhos(c+1,:) = matrizSelecionados(indicepai2,:);
        else
            if (probcruzamento > TaxaCruzamento)
             matrizFilhos(c,:) = matrizSelecionados(indicepai1,:);
             matrizFilhos(c+1,:) = matrizSelecionados(indicepai2,:);
            end
        end    
        c = c + 2;
    end
    
    
    % Muta��o (m�todo OBM)
    for i = 1 : TamPopulacao
        probmutacao = rand;
        if (probmutacao <= TaxaMutacao)
            pos1 = 0;
            pos2 = 0;
            while ((pos1 == pos2)||(pos1 == 0)||(pos2 == 0))
                pos1 = round(rand * TamMatriz);
                pos2 = round(rand * TamMatriz);
            end
            aux = matrizFilhos(i,pos1);
            matrizFilhos(i,pos1) = matrizFilhos(i,pos2);
            matrizFilhos(i,pos2) = aux;
        end   
    end
    
    
    % Atualiza o conjunto de estados
    for a = 1 : TamPopulacao
        matriz_individuo(a,:) = matrizFilhos(a,:);
    end
    
    % Incrementa gera��o
    ger = ger + 1;
end

fprintf('\n\nBusca em: 100'); fprintf(' por cento\n\n');
[val idc] = sort(xfuncaoObj);
fprintf('\nGerando os resultados e os gr�ficos... \n');
fprintf('-------------------------------\n\n');

% Mostra resultados
fprintf('* Gera��o: %d\n', ger);
fprintf('* Melhor Estado:\n\n')
disp(xindividuo(ger-1,:));
fprintf('* Fun��o de Fitness = %f\n', xfitness(ger-1));
fprintf('* Fun��o Objetivo = %f\n', xfuncaoObj(ger-1));


% Gr�ficos: Fitness e Fun��o Objetivo
figure;
subplot(2,1,1)
plot(xfitness,'k');
legend('Fitness');
xlabel('Gera��o');

subplot(2,1,2)
plot(xfuncaoObj, 'b');
legend('F. Objetivo');
xlabel('Gera��o');

figure;
plot(vMediafitness, 'r');
legend('M�dia Fitness');
xlabel('Gera��o');
