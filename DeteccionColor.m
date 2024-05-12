clc; clear all; close all;

% Obtener la lista de cámaras disponibles
camList = webcamlist;

% Seleccionar la cámara que deseas usar (por ejemplo, la primera de la lista)
selectedCam = camList{1};

% Crear el objeto de la cámara seleccionada
cam = webcam(selectedCam);

% Inicializar contadores
contador1 = 0; % Para objetos azules
contador2 = 0; % Para objetos rojos

% Resto del código...
wb = waitbar(0,'-','Name','Espera..','CreateCancelBtn','delete(gcbf)');
i = 0;
while true
    img0 = snapshot(cam);
    
    % Detectar objetos de color azul
    img_blue = imsubtract(img0(:,:,3), rgb2gray(img0));
    bw_blue = im2bw(img_blue, 0.13);
    bw_blue = medfilt2(bw_blue);
    bw_blue = imopen(bw_blue, strel('disk',1));
    bw_blue = bwareaopen(bw_blue, 3000); % Elimina área menor a 3000px
    bw_blue = imfill(bw_blue, 'holes');
    [L_blue, N_blue] = bwlabel(bw_blue);
    
    % Detectar objetos de color rojo
    img_red = imsubtract(img0(:,:,1), rgb2gray(img0));
    bw_red = im2bw(img_red, 0.13);
    bw_red = medfilt2(bw_red);
    bw_red = imopen(bw_red, strel('disk',1));
    bw_red = bwareaopen(bw_red, 3000); % Elimina área menor a 3000px
    bw_red = imfill(bw_red, 'holes');
    [L_red, N_red] = bwlabel(bw_red);
    
    %-----------------regionprops------------------
    prop_blue = regionprops(L_blue);
    prop_red = regionprops(L_red);
    %----------------------------------------------
    
    imshow(img0);
    
    % Dibujar objetos detectados en color azul
    for n = 1:N_blue
        c = round(prop_blue(n).Centroid); % obtener centroide
        rectangle('Position',prop_blue(n).BoundingBox,'EdgeColor','b','LineWidth',2); % dibujar rectangulo
        text(c(1), c(2), strcat('X:', num2str(c(1)), ' \newline', ' Y:', num2str(c(2))), 'Color', 'blue'); % Agregar coordenada
        line([640/2 640/2], [0 480],'Color','red','LineWidth',2); % Dibuja línea vertical
        line([0 640], [480/2 480/2],'Color','red','LineWidth',2); % Dibuja línea horizontal
        contador1 = contador1 + 1; % Incrementar contador de objetos azules
    end
    
    % Dibujar objetos detectados en color rojo
    for n = 1:N_red
        c = round(prop_red(n).Centroid); % obtener centroide
        rectangle('Position',prop_red(n).BoundingBox,'EdgeColor','r','LineWidth',2); % dibujar rectangulo
        text(c(1), c(2), strcat('X:', num2str(c(1)), ' \newline', ' Y:', num2str(c(2))), 'Color', 'red'); % Agregar coordenada
        line([640/2 640/2], [0 480],'Color','red','LineWidth',2); % Dibuja línea vertical
        line([0 640], [480/2 480/2],'Color','red','LineWidth',2); % Dibuja línea horizontal
        contador2 = contador2 + 1; % Incrementar contador de objetos rojos
    end
    
    %__________________    
    if ~ishandle(wb)
        break
    else
        waitbar(i/10, wb, ['num: '  num2str(i)]);
    end
    %___________________
    i = i + 1;
    pause(0.001);
end
clear cam;