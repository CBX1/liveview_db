defmodule PokemonDb.M do
  alias PokemonDb.Repo
  alias PokemonDb.Location
  alias PokemonDb.MoveList
  import PokemonDb.MoveList
  def on do
    IO.puts "test"
  end
  def read do
      {:ok, contents} = File.read("assets/static/location.txt")
      map = contents |> String.split("#-------------------------------") |> tl
    Enum.map(map, fn string -> main(string) end)
  end

  def main(string) do
     o = string |> String.split("\n")
     [_,name, chance | pokemons] = o

   changeset = Location.changeset(
       %Location{
            name: substr(name) ,
            encounterChance: encWhere(chance |> String.split(",")),
            encounterPresent: encPresent(pokemons |> Enum.map(fn string -> substrC(string) end))})
    if changeset.valid? do
        case Repo.insert(changeset) do
            {:ok, location} ->
                IO.puts("Record for #{location.name} was created.")
                changeset.data.name
            {:error, changeset} ->
                IO.inspect(changeset.errors)
                changeset.data.name
        end

    else
        IO.inspect(changeset.errors)
    end

end


  def substr(string) do
      {a,_} = :binary.match(string, " ")
      st = String.slice(string, a, string |> String.length)
      {a,_} = :binary.match(string, " ")
      String.slice(st, a, st |> String.length )
  end

  def encWhere(data) do
       %{:grassEncounter => data |> hd |> Integer.parse |> elem(0), :caveEncounter => data |> tl |> hd |> Integer.parse |> elem(0), :surfEncounter => data |> tl |> tl |> hd |> Integer.parse |> elem(0)}
  end

  def encPresent(data) do
     {_, res} =  Enum.reduce(data, {nil, %{}}, fn datum, {prev_value, result} ->
      if value_type?(datum) do
          {datum, Map.put(result, datum, [])}
      else
          {prev_value, Map.update!(result, prev_value, fn prev_values -> [datum | prev_values] end)}
      end
      end)
      res
  end

  def substrC(string) do
      try do
      {a,_} = :binary.match(string, ",")
      String.slice(string, 0, a)
      rescue
          MatchError -> string
      end
  end

  def value_type?(value) do
  value in ["Land", "FishingRod", "LandNight", "Cave"]
  end
end

defmodule C do
    alias PokemonDb.PokemonLocation
    alias PokemonDb.Repo
    alias PokemonDb.M
    alias PokemonDb.Main

    def onn do
        IO.puts "test"
      end
  def read do
      {:ok, contents} = File.read("assets/static/location.txt")
      newnewmap = contents |> String.split("#-------------------------------") |> tl |> Enum.map( fn string -> string |> String.split("\n") |> check end)
      b = newnewmap |> Enum.map(fn string -> string |> comma_substr |> Enum.uniq end) |>  List.flatten() |> Enum.map(fn string -> {string, pres(string,newnewmap)} end) |> Enum.uniq()
      # Returns tuple in the form of {Name, [Location1,Location2,...]}
      M.read
      array_of_names = Main.read
     {b |> hd |> addPok(array_of_names),b |> tl |> hd |> get_location}
  d = Enum.map(b, fn string -> {addPok(string,array_of_names), get_location(string)} end)
d |> Enum.map(fn s -> zipV(s |> elem(0), s |> elem(1)) end)

    end

    def zipV(z,[]) do
    end

    def zipV(z,list) do
        changeset = PokemonLocation.changeset(%PokemonLocation{pokemon_id: z, location_id: list |> hd })
        if changeset.valid? do
            case Repo.insert(changeset) do
                {:ok, pokemon_location} -> IO.puts("Record for { #{pokemon_location.pokemon_id}, #{pokemon_location.location_id} } was created.")
                {:error, changeset} -> IO.inspect(changeset.errors)
            end
        else
            IO.inspect(changeset.errors)
        end
        zipV(z, list |> tl)
    end

  def addPok(string,array_of_names) do
         b =  string |> elem(0)
         Enum.filter(array_of_names,fn {_,c} -> c == b end) |> hd |> elem(0)


    end

  def get_location(string) do
    b = string |> elem(1)
    Enum.map(b, fn string1 -> changeLoc(string1) end)
  end

  def changeLoc(string) do
     {:ok, data} = Repo.query("SELECT * FROM locations WHERE name='#{string}'")
     data.rows |> hd |> hd
  end

  def changePok(string, a) do
    a |> Enum.filter(fn string1 -> string1.name == string end)
  end

  def substrL(string) do
      {a,_} = :binary.match(string, " ")
      st = String.slice(string, a, string |> String.length)
      {a,_} = :binary.match(string, " ")
      String.slice(st, a, st |> String.length )
  end

  def pres(_, []) do
      []
  end
  def pres(string, [a|b]) do
      v = hd(a)
      bv = a |> Enum.join(" ")
      if(String.contains?(bv, string)) do
          [v |> substrL ] ++ pres(string, b)
      else
          pres(string, b)
      end

  end

  def comma_substr(string) do
      string = tl(string)
      Enum.map(string, fn string -> substr(string) end )
  end

  def substr(string) do
      {a,_} = :binary.match(string, ",")
      String.slice(string, 0, a)
  end

  def check(string) do
     Enum.filter(string, fn d -> !(d == "" || Regex.match?(~r{[0-9][0-9]*,[0-9][0-9]*,[0-9][0-9]*}, d) || value_type?(d) )  end)
  end

  def value_type?(value) do
      value in ["Land", "FishingRod", "LandNight", "Cave"]
  end

end


defmodule PokemonDb.Main do
    alias PokemonDb.Repo
    import Ecto.Changeset
    alias PokemonDb.BaseStat
    alias PokemonDb.Move
    alias PokemonDb.Pokemon
    alias PokemonDb.MoveList
    alias PokemonDb.Tm
    import Ecto.Query
  def read do
      {:ok, contents} = File.read("assets/static/pokemon.txt")
      newmap = contents|> String.split("#-------------------------------") |> tl |> Enum.map( fn string -> string |> String.split("\n") end )
       tms = Tm.read
        #  Enum.map(newmap, fn str -> parse(str,tms) end)
      test1 =  newmap |> tl |> hd |> parse(tms)
        # test2 = newmap |> hd |> parse(tms)

end

    def parse(da,tm_list) do #This is a really long function that just parses a given text blob of a Pokemon
        data = Enum.filter(da, fn string -> string != "" end)
        [pnum,pname,internal_name,ptype1,ptype2 | other_data] = data
        IO.inspect pname
        pnum = pnum
                |> String.slice(1..-2)
                |> Integer.parse
                |> elem(0)
        pname = pname
                |> String.slice(5..String.length(pname))

        internal_name = internal_name
                                |> String.slice(13..String.length(internal_name))
        ptype1 = ptype1
                    |> String.slice(6..String.length(ptype1))

        data = parser2(ptype2,data)
        data_after_type2 = Map.fetch(data, :newdata)
        {:ok, data_after_type2} = data_after_type2

        {:ok, ptype2} = Map.fetch(data, :type2)
        [bst, gender_rate, growth_rate,base_exp,effort_points,rarity,happy, regular_abilities | other_data] = data_after_type2

        [hp, atk, def, speed, spa, spd]= bst
                                            |> String.slice(10..String.length(bst))
                                            |> String.split(",")
         base_stats = %BaseStat{
            HP: hp
                    |> Integer.parse
                    |> elem(0),
            ATK: atk
                    |> Integer.parse
                    |> elem(0),
            DEF: def
                    |> Integer.parse
                    |> elem(0),
            SPEED: speed
                        |> Integer.parse
                        |> elem(0),
            "Sp. ATK": spa
                        |> Integer.parse
                        |> elem(0),
            "Sp. DEF":  spd
                            |> Integer.parse
                            |> elem(0)
          }


       IO.inspect [hp, atk, def, speed, spa, spd]= effort_points
          |> String.slice(13..String.length(effort_points))
          |> String.split(",")

        effort_points = %BaseStat{
                HP: hp
                        |> Integer.parse
                        |> elem(0),
                ATK: atk
                        |> Integer.parse
                        |> elem(0),
                DEF: def
                        |> Integer.parse
                        |> elem(0),
                SPEED: speed
                            |> Integer.parse
                            |> elem(0),
                "Sp. ATK": spa
                            |> Integer.parse
                            |> elem(0),
                "Sp. DEF":  spd
                                |> Integer.parse
                                |> elem(0)
        }

        growth_rate = growth_rate
                                |> String.slice(11..String.length(growth_rate))

        regular_abilities = regular_abilities
                                            |> String.slice(10..String.length(regular_abilities))
                                            |> String.split(",")


        other_data = other_data
                            |> conjure()
        {:ok, hidden_ability} = Map.fetch(other_data, :hidden)
        {:ok, data} = Map.fetch(other_data, :data)
        [all_moves | other_data] = data
        all_moves = all_moves
                        |> String.slice(6..String.length(all_moves))
                        |> String.split(",")
                        |> parese(pnum, "Learns at Level ")
        nparse = data |> tl |> eggMoves()
        {:ok, egg_moves_noschema} = Map.fetch(nparse, :egg_moves)
        egg_moves_schema = egg_moves_noschema |> parese(pnum, "Egg Move")
        unnatural_moves =  search_tm_list(internal_name, tm_list)
        natural_moves = all_moves ++ egg_moves_schema ++ unnatural_moves ++ unnatural_moves

        {:ok, data} = Map.fetch(nparse, :newestdata)


        [_,_,_,_,_,_,_,_,pokedex_entry | last_data] = data
        pokedex_entry = pokedex_entry
                             |> String.slice(8..String.length(pokedex_entry))

        {:ok, last_data} =Map.fetch( last_data
                                            |> item_rarity_Check(),
                                    :ndata)
        {:ok, last_data} = Map.fetch(last_data
                                            |> item_rarity_Check(),
                                    :ndata
                                    )
        {:ok, last_data} = Map.fetch(last_data
                                            |> item_rarity_Check(),
                                    :ndata
                                    )


        [_,_,evolution | _] = last_data
                            |> check
                            |> check

        evolution = evolution
                      |> String.split("=")
                      |> tl
                      |> hd
                      |> String.split(",")
                      |>  convert()

        changeset_pokemon =  PokemonDb.Pokemon.changeset(%PokemonDb.Pokemon{
            :p_num => pnum,
            :name => pname, :type1 => ptype1,
            :type2 => ptype2, :growth_rate => growth_rate,
            :regular_abilities => regular_abilities,
            :hidden_ability => hidden_ability,
            :description => pokedex_entry,  :evolution => evolution,
            :internal_name => internal_name, :base_stat => base_stats, :moves => natural_moves,
            ev: effort_points
            })

        if changeset_pokemon.valid? do
                case Repo.insert(changeset_pokemon, on_conflict: [set: [moves: changeset_pokemon.data.moves,]], conflict_target: :internal_name) do
                    {:ok, pokemon} ->
                        IO.puts("Record for #{pokemon.name} was created.")
                        {changeset_pokemon.data.p_num,  internal_name}
                    # Tuple for many-many relation
                    {:error, changeset} ->
                        IO.inspect(changeset.errors)
                        {changeset_pokemon.data.p_num,  internal_name}
            end
        end

  end

  def add_Moves(str, pnum) do
    {:ok, t} = Map.fetch(str, :name)
    o = %PokemonDb.MoveList{name: t, moves: [pnum] }
    IO.inspect o
    v = MoveList.changeset(o)
    case Repo.insert(v) do
        {:ok, pokemon} -> str
        {:error, changeset} ->
            IO.inspect changeset
            b= Repo.all(from i in MoveList, where: i.name == ^t, select: i)
            IO.inspect b
            c = MoveList.changeset(b |> hd, %{moves: Enum.uniq(( b |> hd ).moves  ++ [pnum])  })
            Repo.update(c)
            str
    end
  end


  def par(string) do
   if (string |> hd) =~ "Pokedex" do
     string |> hd
   else
    string |> tl |> hd
   end
  end



  def search_tm_list(name, tm_list) do
      data_tm = tm_list |> Map.fetch(:tm)
    {:ok, tms} = data_tm
    IO.inspect name
   tms_list = tms  |>  Enum.filter(fn str -> check_map(str,name) end)
     {:ok, data_hm} = tm_list |> Map.fetch(:hm)
     hm_list = data_hm  |>  Enum.filter(fn str -> check_map(str,name) end)
     {:ok, move_tutor_data} =tm_list |> Map.fetch(:move)
     move_tutor_list = move_tutor_data  |>  Enum.filter(fn str -> check_map(str,name) end)

     return_move_list(tms_list ++ hm_list ++ move_tutor_list)
  end


   def check_map(data, str) do
    {:ok, data_str} = Map.fetch(data,:pokemon)
    IO.inspect str
    data_str =~ str

  end
  def return_move_list([]) do
    []
  end

  def return_move_list(move_list) do
     data =  move_list |> hd
     learn_method = data |> Map.keys |> hd
     changeset = %Move{learn: learn_method |> Atom.to_string, name: data |> Map.fetch(learn_method) |> elem(1)}
        [changeset] ++ return_move_list(move_list |> tl)

  end

  def check(ddd) do
      if form_name(ddd |> hd) == true do
          ddd |> tl
      else
          ddd
      end
  end
  def form_name(dd) do
      (dd =~ "FormName" || dd =~ "BattlerPlayerY")
  end
  def conjure(data) do
      if data |> hd =~ "HiddenAbility" do
          %{:hidden => data |> hd |> String.split("=") |> tl |> hd, :data => data |> tl}
      else
          %{:hidden => nil, :data => data}
      end

  end

  def convert([]) do
      []
  end
  def convert(d) do
      if d == [""] do
          nil
      else
           [%{d |> tl |> hd => d |> tl |> tl |>hd, "name" => d |> hd}] ++ convert(d |> tl |> tl |> tl)
      end
  end
  def parese(nil,_,_) do
    []
  end
  def parese([],_,_) do
      []
  end
  def parese(e,p_id,how_learn) do
    cond do
        how_learn =~ "Learns at Level" ->
            IO.inspect e |> tl |> hd
            b = Repo.all(from m in MoveList, select: m.internal_name, where: m.name == ^(e |> tl |> hd)) |> hd
            [%Move{name: b, learn: how_learn <> hd(e)}] ++ parese(e |> tl |> tl,p_id, how_learn)
        how_learn =~ "Egg Move" ->
             b = Repo.all(from m in MoveList, select: m.internal_name, where: m.name == ^(e |>  hd)) |> hd
            [%Move{name: b, learn: "Egg Move"}] ++ parese(e |> tl, p_id, how_learn)
        end
  end
  def parser2(v, data) do
      if v  =~ "Type2" do
         type =  v |>  String.slice(6, String.length(v))
         %{:type2 => type, :newdata => data |> tl |> tl |> tl |> tl |> tl }
      else
          %{:type2 => nil, :newdata => data |> tl |> tl |> tl |> tl }
      end

  end

  def eggMoves(data) do
      if data |> hd =~ "EggMoves" do
          %{:egg_moves => data |> hd |> String.slice(9..String.length(data |> hd)) |> String.split(","), :newestdata => data |> tl}

      else
          %{:egg_moves => nil , :newestdata => data}
      end
  end

  def item_rarity_Check(data) do
      if data |> hd |> is_item() do
          %{:item => data |> hd |> String.split("=") |> tl |> hd, :ndata => data |> tl}
      else
          %{:item => nil, :ndata => data}
      end
  end

  def is_item(data) do
      data =~ "WildItemCommon" || data =~ "WildItemUncommon" || data =~ "WildItemRare"
  end
end


# TM, HM, Move Tutor List
defmodule PokemonDb.Tm do
    import Ecto.Query
    alias PokemonDb.MoveList
    alias PokemonDb.Repo

    def read do
        {:ok, contents} = File.read("assets/static/tm.txt")
        array_generalform = contents |> String.split("#================================================================") |> Enum.filter(fn str -> str != "" end)
        [_,tm_list, _,hm_list, _, move_tutors | _] = array_generalform
        # IO.inspect tm_list
        # IO.inspect hm_list
        # IO.inspect move_tutors
        # IO.inspect array_generalform
        tm_list= tm_list |> String.split("\n") |> Enum.filter(fn str -> str != "" end) |> create_list("tm")
         hm_list = hm_list |> String.split("\n") |> Enum.filter(fn str -> str != "" end) |> create_list("hm")
        move_tutors = move_tutors |> String.split("\n") |> Enum.filter(fn str -> str != "" end) |> create_list("tutor")
       %{tm: tm_list, hm: hm_list, move: move_tutors}
       end

    def create_list([],_) do
        []
    end
    def create_list(content,type) do
        cond do
            type =~ "tm" ->
                c = content |> hd |> String.slice(1..(String.length(content |> hd) -2) )
                IO.inspect c
                 name = Repo.all( from m in MoveList, where: m.name == ^c, select: m.internal_name) |> hd
                # IO.inspect c
                 [%{"Learns via TM": name, pokemon: content |> tl |> hd}]
                 ++ create_list(content |> tl |> tl,type)
            type =~ "hm" ->
                c = content |> hd |> String.slice(2..(String.length(content |> hd) -2) )
                IO.inspect c
                name = Repo.all( from m in MoveList, where: m.name == ^c, select: m.internal_name) |> hd
                [%{"Learns via HM": name, pokemon: content |> tl |> hd |> String.slice(1..(String.length(content |> tl |> hd)))}]
                ++ create_list(content |> tl |> tl,type)
            type =~ "tutor" ->
                c = content |> hd |> String.slice(1..(String.length(content |> hd) -2) )
                IO.inspect c
                IO.inspect c
                 name = Repo.all( from m in MoveList, where: m.name == ^c, select: m.internal_name) |> hd
                [%{"Learns via Move Tutor": name, pokemon: content |> tl |> hd}]
                ++ create_list(content |> tl |> tl,type)
        end
        #The names of the tms start with L to normalize data manipulation for each array of maps

    end

end

# Pre Evolutions
defmodule Tno do
    import Ecto.Query
alias PokemonDb.{
    Repo,
    Pokemon
}
    def read do
        a = Repo.all(from Pokemon)
        b = a |> Enum.map(fn str -> n(str) end)
        b
    end

    def n(t) do

         if t.evolution != nil do
          o = t.evolution |> Enum.map(fn str -> getPok(Map.fetch(str, "name") |> elem(1), t.name) end)
         else
            nil
        end
    end

    def getPok(name,o) do
        a = Repo.all(from p in Pokemon, where: p.internal_name == ^name) |> hd
        if a.evolution == nil do
            b = Pokemon.changeset(a, %{:evolution =>  [%{"name" => o, "Evolves" => "from"   }]})
            Repo.update(b)
        else
           b = Pokemon.changeset(a, %{:evolution =>  a.evolution ++ [%{"name" => o, "Evolves" => "from"   }]})
           Repo.update(b)
        end

    end

end


#Moves
defmodule PokemonDb.MoveData do
    alias PokemonDb.MoveList
    alias PokemonDb.Repo
    require IEx
    def read do
        {:ok, contents} = File.read("assets/static/o.txt")
        c = contents |> String.split("\n")
          c |> Enum.map(fn str -> parse(str |> String.split("\"")) end)

          Repo.insert(%MoveList{name: "FLY", internal_name: "Fly", description: "The user flies up into the sky and then strikes its target on the next turn.", type: "FLYING", forc: "PHYSICAL", power: 90, acc: 100}, on_conflict: [set: [basepp: 24, acc: 95]], conflict_target: :name)
          Repo.insert(%MoveList{name: "WATERFALL", internal_name: "Waterfall", description: "Waterfall deals damage and has a 20% chance of causing the target to flinch (if the target has not yet moved).", type: "WATER", forc: "PHYSICAL", power: 80, acc: 100}, on_conflict: [set: [basepp: 24, acc: 100]], conflict_target: :name)

    end
    def parse([a,b]) do

[_,internal_name, name,_, power , type, forc, acc, basepp | _] = a |> String.split(",")
# name and internal name are switched because the data is being upserted
{power, _} = power |> Integer.parse
{acc, _} = acc |> Integer.parse
{basepp, _} = basepp |> Integer.parse
data = %{internal_name:  name, basepp: basepp, name: internal_name, type: type, power: power, acc: acc, forc: forc, description: b}
a = MoveList.changeset(%MoveList{}, data)
Repo.insert(a, on_conflict: [set: [internal_name: a.changes.internal_name, type: a.changes.type, power: a.changes.power, forc: a.changes.forc, description: a.changes.description]],
conflict_target: :name)
    end

    def parse(  [a,d,_] ) do

[_,internal_name, name,_, power , type, forc, acc, basepp | _] = a |> String.split(",")
# name and internal name are switched because the data is being upserted
{power, _} = power |> Integer.parse
{acc, _} = acc |> Integer.parse
{basepp, _} = basepp |> Integer.parse
data = %{internal_name:  name, basepp: basepp, name: internal_name, type: type, power: power, acc: acc, forc: forc, description: d}
a = MoveList.changeset(%MoveList{}, data)
Repo.insert(a, on_conflict: [set: [internal_name: a.changes.internal_name, type: a.changes.type, power: a.changes.power, forc: a.changes.forc, description: a.changes.description]],
conflict_target: :name)

end

end
