#LiwcDreams 1.0
#por Mayte H. Laureano y H. Calvo
#
#Este programa abre los diccionarios de LIWC
#y los carga en memoria.
#Posteriormente abre el corpus de sueños y análisis, y para cada palabra encontrada en
#éste, lo busca en los diccionarios de LIWC para finalmente imprimir un vector
#con el conteo de cada una de éstas.


open WORDS, "<words.liwc" or die "No puedo abrir el diccionario de LIWC\n";
open CAT, "<categories.liwc" or die "No puedo abrir la lista de categorías\n";


%globcat=();
$verbose=0;		#variable global para imprimir información adicional para debuggeo

use utf8;		#para poder leer acentos y caracteres en español

#Carga el diccionario de categorías en memoria
while (<CAT>) {
   chomp;
   /(.*)\t(.*)/;
   $liwccats{$1}=$2;
}

#Carga el diccionario de palabras con sus categorías en memoria
while (<WORDS>) {
   chomp;
   /(.*?)\t(.*)/;
   $liwcwords{$1}=$2;
}

#Función para hacer la agregación de categorías de palabras
sub liwc_cuenta {
   $palabra = shift; #se almacena la palabra para contabilizar

   @categorias=();

   if ($liwcwords{$palabra} ne "") { 		#Si encuentra la palabra tal cual
      @categorias = split /\t/,$liwcwords{$palabra}; #Obtén las categorías
   }

   #en el caso de que haya palabras como dejad*, debe coincidir con 
   #dejado, dejada, dejados, dejadas, dejadez, etc.
   else { 									#Buscar en cada entrada en el diccionario
      foreach $llave (keys %liwcwords) {
          $ultimo_caracter = substr($llave, -1); #Buscar el último caracter

          if ($ultimo_caracter ne "*") { #Si no es asterisco, no es necesario procesarlo
             next;
          }

          $busca=substr($llave, 0, -1); #Para las entradas que contienen asterisco, quitárselo
          
          if ($palabra =~ /^$busca\w*/) { #Buscar para cualquier cantidad de otros caracteres
             @categorias = split /\t/,$liwcwords{$llave};
          }
      }
   }

   foreach $categoria (@categorias) {
      $globcat{$liwccats{$categoria}}+=1; #Aumenta el conteo de categorías globales vistas
   }
} #End sub.

#Función para desplegar los totales de categorías vistas.
sub liwc_total {
    foreach $categoria (sort keys %globcat) {
       print "$categoria:$globcat{$categoria}\t" if $verbose;
    }
} #End sub.

#Función para inicializar las categorías a cero (todas)
sub liwc_zero {
    foreach $categoria (values %liwccats) {
       $globcat{$categoria}=0;
    }
} #End sub.

sub liwc_doc {
   $document = shift;
   liwc_zero();

   @words = split /\b/,$document;
   foreach $word (@words) {
      #print "$word\n";
      liwc_cuenta($word);
   }
   liwc_total();
}

#Main:
use JSON;

# Nombre del archivo JSON con las descripciones de sueños
my $archivo_json = "corpus_oneiric_gpt240106.json";

# Abrir el archivo para lectura
open my $fh, '<', $archivo_json or die "No se pudo abrir el archivo $archivo_json: $!";

# Leer el contenido del archivo en una variable escalar
my $contenido_json = do { local $/; <$fh> };

# Cerrar el archivo
close $fh;

# Decodificar el contenido JSON en una estructura de datos Perl
my $datos = decode_json($contenido_json);

$stories=$datos->{'oneiric_stories'};

$px=1;
foreach $story (@$stories) { 				#para cada paciente
   $dreams=$story->{'dreams'}; 				#obtiene sus sueños
   $d=1; 									#inicializa el contador de sueños a 1
   $pxname=$story->{'context'}->{'name'}; 	#obtiene el nombre del paciente
   warn "$pxname\n";   						#se imprime en consola
   foreach $dream (@$dreams) {				#para cada sueño de cada paciente
      print "\nPX$px\t$pxname\tD$d\tA0\t\t";#imprime el nombre del paciente y número de sueño
      liwc_doc($dream->{'dream'});			#imprime los valores de las características LIWC
      $d+=1;								#incrementa número de sueño
   }
   $a=1;									#inicializa contador de análisis a 1
   $analysts=$story->{'analysts'};
   foreach $analyst (@$analysts) {			#para cada analista
      $ananame=$analyst->{'analyst'};		#obtiene el nombre del analista
      print "\nPX$px\t$pxname\tD0\tA$a\t$ananame\t";
								#imprime el nombre del paciente y el número de análisis
      liwc_doc($analyst->{'analysis'});		#imprime los valores de las características LIWC
      $a+=1;								#incrementa el número de analista
   }
   $px+=1;									#incrementa el número de paciente
}
