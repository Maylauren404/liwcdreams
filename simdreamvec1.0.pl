use Data::Dumper;							#para debuggeo: imprimir estructuras completas
use Scalar::Util qw(looks_like_number);		#para determinar si una variable contiene un número o no

# Función para calcular semejanzas entre dos vectores usando
# * Similitud coseno
# * Jaccard
# * Distancia Euclidiana
# Por Mayte H. Laureano e Hiram Calvo
# Licencia Apache 2.0.
# Modificaciones posibles, citando a los autores originales y listando cambios.


# Función utilizada para calcular la semejanza coseno de dos vectores
sub cosine_similarity {
    my ($vec1, $vec2) = @_;
    my $dot_product = 0;
    my $norm_a = 0;
    my $norm_b = 0;
    
    $nvec1=scalar @$vec1;

    for ($i = 0; $i < $nvec1; $i++) {
        $dot_product += $vec1->[$i] * $vec2->[$i];
        $norm_a += $vec1->[$i] ** 2;
        $norm_b += $vec2->[$i] ** 2;
    }

    if ($norm_a == 0 || $norm_b == 0) {
        return 0; # Evitar división por cero
    }

    return $dot_product / (sqrt($norm_a) * sqrt($norm_b));
}

# Para calcular la similitud de Jaccard entre dos conjuntos representados como vectores
# Similitud de Jaccard=|Intersección de conjuntos| / |Unión de conjuntos|

sub jaccard_similarity {
    my ($set1, $set2) = @_;

    # Convertir los vectores en conjuntos (hash)
    my %set1_hash = map { $_ => 1 } @$set1;
    my %set2_hash = map { $_ => 1 } @$set2;

    # Calcular la intersección de conjuntos
    my $intersection_count = 0;
    foreach my $element (keys %set1_hash) {
        if (exists $set2_hash{$element}) {
            $intersection_count++;
        }
    }

    # Calcular la unión de conjuntos
    my %union_hash = (%set1_hash, %set2_hash);
    my $union_count = keys %union_hash;

    # Calcular la similitud de Jaccard
    my $jaccard_similarity = $intersection_count / $union_count;

    return $jaccard_similarity;
}

# Función para calcular la distancia euclidiana (llamada "similarity" para mantener
# homgeneidad, pero es una distancia)

sub euclidean_similarity {
    my ($vec1, $vec2) = @_;

    # Verificar si los vectores tienen la misma longitud
    die "Los vectores deben tener la misma longitud" unless @$vec1 == @$vec2;

    $nvec1=scalar @$vec1;
    my $sum_of_squares = 0;

    #Normaliza por cada vector (horizontalmente) 
    $nvec1tot=0;
    $nvec2tot=0;    
    for ($i = 0; $i < $nvec1; $i++) {    
       $nvec1tot+=$vec1->[$i];
       $nvec2tot+=$vec2->[$i];
	}
    for ($i = 0; $i < $nvec1; $i++) {
       next if (!looks_like_number($vec1->[$i]));	#No procesar si no es un número
       next if $nvec1tot == 0 or $nvec2tot == 0;
	      $vec1->[$i]=$vec1->[$i]/$nvec1tot;
	      $vec2->[$i]=$vec2->[$i]/$nvec2tot;
	}

    for my $i (0 .. $#$vec1) {
        my $difference = $vec1->[$i] - $vec2->[$i];
        $sum_of_squares += $difference * $difference;
    }

    my $distance = sqrt($sum_of_squares);
    return 1-$distance;
}

# Función de prueba para probar las semejanzas
sub ejemplo_de_uso {
	my $vector1 = [1, 2, 3]; # Reemplazar con los valores reales
	my $vector2 = [1, 2000, 30000]; # Reemplazar con los valores reales

	my $similarity = cosine_similarity($vector1, $vector2);
	print "La similitud coseno es: $similarity\n";
}

# Abrir archivo de vectores en el formato obtenido por liwcdreams1.0

open DOC, "<liwcdreams.csv" or die "No puedo abrir el archivo de lectura liwcdreams.csv";

while (<DOC>) {
    chomp;
    @input=split "\t",$_;
    $patientnum=substr($input[0], 2);			#Obtener el número de paciente
    
    #print "\tPX$patientnum:";
    if ($input[2] ne "D0") { 					#Si es un sueño
       $dreamsnum=substr($input[2],1);			#obtiene número de sueño
       my @rest=splice(@input, 3);				#lee el resto de vector de características
       $rest[0]=$input[1];       				#coloca el nombre del paciente
       $dreams[$patientnum][$dreamsnum]=\@rest;	#lee en memoria el sueño para este paciente y este sueño
    }
    else {  									#Si es un análisis
       $analysnum=substr($input[3],1);    		#obtiene el número del análisis
       my @rest=splice(@input, 3);       		#lee el resto de vector de características
       $rest[0]=$input[1];       				#coloca el nombre del paciente
       $analys[$patientnum][$analysnum]=\@rest; #lee en memoria el análisis para este paciente de este analista
    }
}


# Se asume que la estructura de sueños @dreams está definida como:
# @dreams = (
#     [ [1, 2], [3, 4], ... ], # Paciente 0 con múltiples sueños
#     [ [5, 6], [7, 8], ... ], # Paciente 1 con múltiples sueños
#     ...					   # etc
# );

# Esta función calcula el vector promedio de sueños o análisis para cada paciente
sub calculate_average_vector_per_patient {
    my @dreams = @_;
    my @avgvec;

    for my $patientnum (0 .. $#dreams) {		#para cada paciente
        my $dream_count = scalar @{$dreams[$patientnum]};	#obtener el total de sueños o análisis
        my @sum_vector = (0) x scalar @{$dreams[$patientnum][0]}; # Inicializar las columnas de suma a 0

        # Suma los elementos de cada vector
        foreach my $dream (@{$dreams[$patientnum]}) {
            for my $i (0 .. $#{$dream}) {
                $sum_vector[$i] += $dream->[$i];
            }
        }

        # Calcula el promedio para cada característica dividiendo la suma ente el total de sueños o análisis
        for my $i (0 .. $#sum_vector) {
            $sum_vector[$i] /= ($dream_count - 1);
        }

        push @avgvec, \@sum_vector;	#añade a la estructura de @avgvec
    }

    return @avgvec;					#regresa la estructura de promedios de todos los pacientes
}

# Obtiene el promedio de vectores de sueños y de análisis
my @avgdreams = calculate_average_vector_per_patient(@dreams);
my @avganalys = calculate_average_vector_per_patient(@analys);

# Principal:

for $patientnum (1 .. $#dreams-1) { 			#para cada paciente
	$patientname=$dreams[$patientnum][1][0];	#obtener su nombre

    #calcular semejanza entre el promedio de sus sueños y sus análisis
	$similarity = cosine_similarity   ($avgdreams[$patientnum],$avganalys[$patientnum]);
	#$similarity = jaccard_similarity  ($avgdreams[$patientnum],$avganalys[$patientnum]);
	#$similarity = euclidian_similarity($avgdreams[$patientnum],$avganalys[$patientnum]);

    #imprimir número de paciente
    print ($patientnum);
    #imprimir nombre y la similitud entre prom. sueños y prom. analisis
	print "\t$patientname\t$similarity\n";

   	$ai=1;
    foreach $analy (@{$analys[$patientnum]}) {	#para cada análisis de este paciente
        next if @{$analy} == 0; 				# Saltar si no hay análisis
        #Comparar la similitud del análisis con respecto al promedio de análisis
      	$similarity = cosine_similarity($analy,$avganalys[$patientnum]);
		$analystname=$$analy[1];
		print "\t$analystname\t$similarity\t";

        #Comparar la similitud del análisis con respecto al promedio de sueños
      	$similarity = cosine_similarity($analy,$avgdreams[$patientnum]);
		print "$similarity\t";

		#calcular la similitud de este análisis vs. el resto de los analistas
		#tabla de "confusión"
		$aj=1;
		$simtot=0;
	    foreach $analy2 (@{$analys[$patientnum]}) { #para cada analista de este paciente		
	        next if @{$analy2} == 0; 				#Saltar, si no hay análisis
	        #Calcular la similitud entre el analista 1 y el analista 2
	        #(Si es el mismo, será 1.0)
	      	$similarity = cosine_similarity($analy,$analy2);
	      	if ($ai != $aj) {
		      	$simtot+=$similarity;
		    }
			print "$similarity\t";		      	
	      	$aj++;
	    }
	    $padright=7-$aj;							#para imprimir hasta la séptima columna
	    for $i (0..$padright) {
	       print "\t";
	    }
	    
		#Se calcula el promedio de las similitudes de cada analista con los demás.
	    $simavg=$simtot/($aj-2);
	    print "$simavg\n";							
	    
	    $ai++;										#siguiente análisis
    }
}


