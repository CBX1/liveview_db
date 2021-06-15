defmodule M do
  alias PokemonDb.Repo
  alias PokemonDb.Location
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
   changeset = Location.changeset(%Location{name: substr(o|> tl |>hd) , encounterChance: encWhere(o |> tl |> tl |> hd |> String.split(",")), encounterPresent: encPresent(o |> tl |> tl |> tl |> Enum.map(fn string -> lol(string) end))})
    if changeset.valid? do
        case Repo.insert(changeset) do
            {:ok, location} -> IO.puts("Record for #{location.name} was created.")
            {:error, changeset} -> IO.inspect(changeset.errors)
        end
        changeset
    else

    end

end

  def lol(string) do
      substrC(string)
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
    def onn do
        IO.puts "test"
      end
  def read do
      {:ok, contents} = File.read("assets/static/location.txt")
      newnewmap = contents |> String.split("#-------------------------------") |> tl |> Enum.map( fn string -> string |> String.split("\n") |> check end)
      b = newnewmap |> Enum.map(fn string -> string |> comma_substr |> Enum.uniq end) |>  List.flatten() |> Enum.map(fn string -> {string, pres(string,newnewmap)} end) |> Enum.uniq()
      a= M.read
      c = Main.read
        # {:ok, vv}=
        b |> hd |> addPok(c)
        # vv.rows |> hd |> hd
        # b |> tl |>  hd |> addLoc(a)
    d = Enum.map(b, fn string -> {addPok(string,c), addLoc(string,a)} end)
    d |> Enum.map(fn s -> zipV(s |> elem(0), s |> elem(1)) end)

    end

    def zipV(z,[]) do
    end

    def zipV(z,list) do
         Repo.insert!(%PokemonLocation{pokemon_id: z, location_id: list |> hd })
        zipV(z, list |> tl)
    end

  def addPok(string,bv) do
        b =  string |> elem(0)
        d = Enum.filter(bv, fn {a,c} -> c == b end) |> hd
        {e,_} = d
      if e.name =~ "'" do
        {:ok, data} = Repo.query("SELECT * from pokemons WHERE NAME::text LIKE '%Farfetch%'")
        data.rows |> hd |> hd
      else
        {:ok, data} = Repo.query("SELECT * FROM pokemons WHERE name='#{e.name}'")
        data.rows |> hd |> hd
      end


    end

  def addLoc(string,a) do
    b = string |> elem(1)
    Enum.map(b, fn string1 -> changeLoc(string1,a) end)
  end

  def changeLoc(string, a) do
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


defmodule Main do
    alias PokemonDb.Repo
    import Ecto.Changeset
    alias PokemonDb.BaseStat
    alias PokemonDb.Move
    alias PokemonDb.Pokemon
  def read do
      {:ok, contents} = File.read("assets/static/pokemon.txt")
      newmap = contents|> String.split("#-------------------------------") |> tl |> Enum.map( fn string -> string |> String.split("\n") end )
       tms = Tm.read
    #   Enum.map(newmap, fn str -> parse(str,tms) end)
      newmap |> hd |> parse(tms)

end

  def parse(da,tm_list) do #This is a really long function that just parses a given text blob of a Pokemon
      data = Enum.filter(da, fn string -> string != "" end)
      pnum = data |> hd |> String.slice(1..( String.length(data |> hd) - 2) ) |> Integer.parse |> elem(0)
      # IO.puts "ncumber ok"
       pname = data |> tl |> hd |> String.slice(5, String.length(data |> tl |> hd))
      #  # IO.puts "name ok"
      #  # IO.puts "currently #{pname}"
       ptype1 = data |> tl |> tl |> tl |> hd |> String.slice(6, String.length(data |> tl |> tl |> hd))
      #  # IO.puts "type 1 ok"
       v = data |> tl |> tl |> tl |> tl |> hd
        newinfo = parser2(v,data)
       ndata = Map.fetch(newinfo, :newdata)
       {:ok, content} = ndata
       {:ok, ptype2} = Map.fetch(newinfo, :type2)
      #  # IO.puts "type 2 ok"
       vv =["HP", "ATK", "DEF", "SPEED", "Sp. ATK", "Sp. DEF"]
      ase_stats = vv |>
       Enum.zip(content |> hd |> String.slice(10..String.length(content |> hd))
       |> String.split(","))

      # IO.puts "Base stats ok"

      #  # IO.puts "Gender Rate ok"
       growth_rate = content |> tl |> tl |> hd |> String.slice(11..String.length( content |> tl |> tl |> hd))
      # # IO.puts "Growth Rate ok"
       base_exp = content |> tl |> tl |> tl |> hd |> String.slice(8..String.length(content |> tl |> tl |> tl |> hd))
      # # IO.puts "Base Exp ok"
       effort_points = vv |> Enum.zip(content |> tl  |> tl |> tl |> tl |> hd |> String.slice(13..String.length(content |> tl  |> tl |> tl |> tl |> hd)) |> String.split(",")) |> Map.new()
      #  # IO.puts "Effort points OK"
       rarity = content |> tl  |> tl |> tl |> tl |> tl |> hd |> String.slice(9..String.length(content |> tl  |> tl |> tl |> tl |> tl |> hd))
      # # IO.puts "Rarity OK"
       happiness = content |> tl  |> tl |> tl |> tl |> tl |> tl |> hd |> String.slice(10.. String.length(content |> tl  |> tl |> tl |> tl |> tl |> hd))
      # IO.puts "happy ok"
       regular_abilities =  content |> tl  |> tl |> tl |> tl |> tl |> tl |> tl |> hd |> String.slice(10..String.length(content |> tl  |> tl |> tl |> tl |> tl |> tl |> tl |> hd)) |> String.split(",")
      # IO.puts "regular abilities ok"
      ond = content |> tl  |> tl |> tl |> tl |> tl |> tl |> tl |> tl |> conjure()
      {:ok, hidden_ability} = Map.fetch(ond, :hidden)
      {:ok, cnn} = Map.fetch(ond, :data)
       # IO.puts "hidden abilities ok"
        all_moves = cnn |> hd |> String.slice(6..String.length(cnn |> hd)) |> String.split(",") |>   parese(pnum, "Learns at Level ")
            nparse = cnn |> tl |> eggMoves()
            {:ok, egg_moves_noschema} = Map.fetch(nparse, :egg_moves)
            IO.puts "#{pname}"
            egg_moves_schema = egg_moves_noschema |> parese(pnum, "Egg Move")
#           unnatural_moves =  search_tm_list(data |> tl |> tl |> hd |>
#    String.slice(13..(String.length(data |> tl |> tl |> hd))),tm_list)
        natural_moves = all_moves ++ egg_moves_schema # ++ unnatural_moves
       {:ok, ncontent} = Map.fetch(nparse, :newestdata)
       # IO.puts "Egg Moves ok"
       egg_groups = ncontent |> hd |> String.slice(14..String.length(ncontent |> hd)) |> String.split(",")
       # IO.puts "Egg Groups ok"
       hatch = ncontent |> tl |> hd |> String.slice(13..String.length(content |> tl |> hd))
      # IO.puts "steps to hatch ok"
      eee =par(ncontent |> tl  |> tl |> tl |> tl |> tl |> tl |> tl)
       pokedex_entry = eee |> String.slice(8..String.length(eee))
      # IO.puts "pxdx entry"

       won = ncontent |> tl  |> tl |> tl |> tl |> tl |> tl |> tl |> tl |> tl |> item_rarity_Check()
       {:ok, wild_common} = Map.fetch(won, :item)
       {:ok, nndata} = Map.fetch(won, :ndata)
       nnndata = nndata |> item_rarity_Check
       {:ok, wild_uncommon} = Map.fetch(nnndata, :item)
       {:ok, weGo} = Map.fetch(nnndata, :ndata)
       adf = weGo |> item_rarity_Check
       {:ok, wild_rare} = Map.fetch(adf, :item)
       # IO.puts "Items Discovered"
       {:ok, ddd} = Map.fetch(adf, :ndata)
       df = ddd |> check() |>check() |> tl |> tl |> hd
       evolution = df  |> String.split("=")  |> tl |> hd |> String.split(",") |>  convert()
        # IO.puts "evolution ok"
        base_stats = %PokemonDb.BaseStat{
            HP: ase_stats |> hd |> elem(1) |> Integer.parse |> elem(0),
            ATK: ase_stats |> tl |> hd |> elem(1) |> Integer.parse |> elem(0),
            DEF: ase_stats |> tl |> tl |> hd |> elem(1) |> Integer.parse |> elem(0),
            SPEED: ase_stats |> tl |> tl |> tl |> hd |> elem(1) |> Integer.parse |> elem(0),
            "Sp. ATK":  ase_stats |> tl |> tl |> tl |> tl |> hd |> elem(1) |> Integer.parse |> elem(0),
            "Sp. DEF":  ase_stats |> tl |> tl |> tl |> tl |> tl |> hd |> elem(1) |> Integer.parse |> elem(0),

            # {"HP", "63"},
            # {"ATK", "67"},
            # {"DEF", "65"},
            # {"SPEED", "70"},
            # {"Sp. ATK", "60"},
            # {"Sp. DEF", "80"}
        }
        changeset_bst = BaseStat.changeset(base_stats)
        if changeset_bst.valid? do
            changeset_pokemon = Pokemon.changeset(%PokemonDb.Pokemon{:p_num => pnum  ,
            :name => pname, :type1 => ptype1,
              :type2 => ptype2, :growth_rate => growth_rate,
                 :regular_abilities => regular_abilities,
                 :hidden_ability => hidden_ability,
                  :description => pokedex_entry,  :evolution => evolution,
               })
            if changeset_pokemon.valid? do
               changeset_pokemon= changeset_pokemon
                    |> put_assoc(:moves, natural_moves)
                    |> put_assoc(:base_stats, base_stats)
               case Repo.insert(changeset_pokemon) do
                {:ok, pokemon} ->
                    IO.puts("Record for #{pokemon.name} was created.")
                    # %{number: pnu, name: data |> tl |> tl |> hd |> String.slice(13..(String.length(data |> tl |> tl |> hd)))}
                {:error, changeset} ->
                    IO.inspect(changeset.errors)
               end
            else
                {:error, IO.inspect(changeset_pokemon.errors)}
            end


        else
            {:error,  IO.inspect(changeset_bst.errors)}
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
   tms_list = tms  |>  Enum.filter(fn str -> check_map(str,name) end)
    {:ok, data_hm} = tm_list |> Map.fetch(:hm)
    hm_list = data_hm  |>  Enum.filter(fn str -> check_map(str,name) end)
    {:ok, move_tutor_data} =tm_list |> Map.fetch(:move)
    move_tutor_list = move_tutor_data  |>  Enum.filter(fn str -> check_map(str,name) end)

    return_move_list(tms_list ++ hm_list ++ move_tutor_list)
  end


   def check_map(data, str) do
    {:ok, data_str} = Map.fetch(data,:pokemon)
    data_str =~ str

  end
  def return_move_list([]) do
    []
  end

  def return_move_list(move_list) do
     data =  move_list |> hd
     learn_method = data |> Map.keys |> hd
     changeset = Move.changeset(%Move{learn: learn_method |> Atom.to_string, name: data |> Map.fetch(learn_method) |> elem(1)})
     if changeset.valid? do
        [changeset] ++ return_move_list(move_list |> tl)
     else
        {:error, IO.inspect(changeset.errors)}
        [] ++ return_move_list(move_list |> tl)
     end
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
            [%Move{name: e |> tl |> hd, learn: how_learn <> hd(e)}] ++ parese(e |> tl |> tl,p_id, how_learn)
        how_learn =~ "Egg Move" ->
            [%Move{name: e |> hd, learn: "Egg Move"}] ++ parese(e |> tl, p_id, how_learn)
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



defmodule Tm do
    def read do
        {:ok, contents} = File.read("assets/static/tm.txt")
        array_generalform = contents |> String.split("#================================================================") |> Enum.filter(fn str -> str != "" end)
       tm_list= array_generalform |> tl |> hd |> String.split("\n") |> Enum.filter(fn str -> str != "" end) |> create_list("tm")
         hm_list = array_generalform |> tl |> tl |> tl |> hd |> String.split("\n") |> Enum.filter(fn str -> str != "" end) |> create_list("hm")
        move_tutors = array_generalform |> tl |> tl |> tl |> tl |> tl |> hd |> String.split("\n") |> Enum.filter(fn str -> str != "" end) |> create_list("tutor")
       list_learn= %{tm: tm_list, hm: hm_list, move: move_tutors}
       end

    def create_list([],_) do
        []
    end
    def create_list(content,type) do
        cond do
            type =~ "tm" ->
                [%{"Learns via TM": content |> hd |> String.slice(1..(String.length(content |> hd) -2) ), pokemon: content |> tl |> hd}]
                ++ create_list(content |> tl |> tl,type)
            type =~ "hm" ->
                [%{"Learns via HM": content |> hd |> String.slice(2..(String.length(content |> hd) -2) ), pokemon: content |> tl |> hd |> String.slice(1..(String.length(content |> tl |> hd)))}]
                ++ create_list(content |> tl |> tl,type)
            type =~ "tutor" ->
                [%{"Learns via Move Tutor": content |> hd |> String.slice(1..(String.length(content |> hd) -2) ), pokemon: content |> tl |> hd}]
                ++ create_list(content |> tl |> tl,type)
        end
        #The names of the tms start with L to normalize data manipulation for each array of maps

    end
end
