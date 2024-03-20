# lecture donnees
mutable struct donnees
  N::Int # nbre de produits
  R::Int # nbre racks
  O::Int # nbre d'ordre
  RS::Int # nbre shelves dans un rack
  S::Vector{Vector{Int}} # matrice produits - racks
  Q::Vector{Vector{Int}} # matrice produits - ordres
  P::Int # nbre de pickers
  Capa::Vector{Int} # capacite des pickers
  FO::Vector{Int} # first orders prioritaires
  SO::Vector{Int} # second orders moins prioritaires

  function donnees(N,R,O,RS,P,Capa,FO,SO)
    this=new()
    this.N=N
    this.R=R
    this.O=O
    this.RS=RS
    this.P=P
    
    # init matrice S
    this.S=[] # vide
    for i in 1:N 
      push!(this.S,[])
    end
    for i in 1:N 
      for j in 1:R
        push!(this.S[i],0)
      end
    end
    # init matrice Q
    this.Q=[] # vide
    for i in 1:N 
      push!(this.Q,[])
    end
    for i in 1:N 
      for j in 1:O
        push!(this.Q[i],0)
      end
    end
    # init matrice Capacite des pickers
    this.Capa=Capa 
    # init matrice FO vide
    this.FO=FO
    # init matrice SO vide
    this.SO=SO
    
    return this
  end
end # fin de la struct donnees


function parseInstance(filepath::String, P::Int, Capa::Vector{Int}, FO::Vector{Int}, SO::Vector{Int})::donnees

  lines = readlines(filepath) 
  line = lines[1]
  line_decompose = split(line)

  # Number of products
  N = parse(Int64, line_decompose[2])
  # println("nbre produits total N ",N)

  # Number of racks
  line = lines[2]
  line_decompose = split(line)
  R = parse(Int64, line_decompose[2])
  # println("nbre racks R ",R)

  # Number of orders
  line = lines[3]
  line_decompose = split(line)
  O = parse(Int64, line_decompose[2])
  # println("nbre ordres O ",O)

  # Number of shelves per rack
  line = lines[5]
  line_decompose = split(line)
  RS = parse(Int64, line_decompose[2])
  # println("nbre shelves par rack ",RS)

  Data = donnees(N,R,O,RS,P,Capa,FO,SO)
  # println(Data.N," ",Data.R," ",Data.O," ",Data.RS)
  
  # for r in 1:R # parcours les racks

  #   num_line=7+r
  #   global line=lines[num_line]
  #   global line_decompose=split(line)
  #   # print("\n rack ",r,"\n")

  #   for i in 1:RS # parcours les shelves 

  #     num_prod=parse(Int64,line_decompose[2*i])
  #     quantite=parse(Int64,line_decompose[1+2*i])

  #     # print(num_prod," ",quantite," ")
  #     # Attention les produits vont de 0 - N-1
  #     Data.S[num_prod+1][r]=quantite

  #   end

  # end

  # for o in 1:O # parcours les ordres

  #   num_line=(7+R+2)+o
  #   global line=lines[num_line]
  #   global line_decompose=split(line)
    
  #   nbre_prod_inside_ordre=parse(Int64,line_decompose[2])
  #   # print("\n ordre ",o," ",nbre_prod_inside_ordre,"\n")

  #   for i in 1:nbre_prod_inside_ordre

  #     num_prod=parse(Int64,line_decompose[2+i])
  #     # Attention numero de produit vont de 0 - N-1
  #     Data.Q[num_prod+1][o]+=1
  #     # println("num produit ", num_prod," ",Data.Q[num_prod+1][o])

  #   end
  
  # end
  Data.S = [[1,0,0], [0,1,0], [0,0,1]]
  Data.Q = [[1,0], [0,1], [1,0]]

  return Data
end
  
  
  
  
  
   