#
# Bialgebroids: Bialgebroids as preadditive categories generated by enhanced quivers
#
# Implementations
#

####################################
#
# representations:
#
####################################

DeclareRepresentation( "IsCapCategoryObjectInAlgebroidRep",
        IsCapCategoryObjectInAlgebroid and
        IsAttributeStoringRep,
        [ ] );

DeclareRepresentation( "IsCapCategoryMorphismInAlgebroidRep",
        IsCapCategoryMorphismInAlgebroid and
        IsAttributeStoringRep,
        [ ] );

####################################
#
# families and types:
#
####################################

# new families:
BindGlobal( "TheFamilyOfObjectsInAlgebroids",
        NewFamily( "TheFamilyOfObjectsInAlgebroids" ) );

BindGlobal( "TheFamilyOfMorphismsInAlgebroids",
        NewFamily( "TheFamilyOfMorphismsInAlgebroids" ) );

# new types:
BindGlobal( "TheTypeObjectInAlgebroid",
        NewType( TheFamilyOfObjectsInAlgebroids,
                IsCapCategoryObjectInAlgebroidRep ) );

BindGlobal( "TheTypeMorphismInAlgebroid",
        NewType( TheFamilyOfMorphismsInAlgebroids,
                IsCapCategoryMorphismInAlgebroidRep ) );

####################################
#
# methods for attributes:
#
####################################

##
InstallMethod( SetOfObjects,
        "for an algebroid",
        [ IsCapCategory and HasUnderlyingQuiver ],
        
  A -> List( Vertices( UnderlyingQuiver( A ) ), o -> A.(String( o ) ) ) );

##
InstallMethod( SetOfGeneratingMorphisms,
        "for an algebroid",
        [ IsCapCategory and HasUnderlyingQuiver ],
        
  A -> List( Arrows( UnderlyingQuiver( A ) ), o -> A.(String( o ) ) ) );

####################################
#
# methods for operations:
#
####################################

##
InstallGlobalFunction( ADD_FUNCTIONS_FOR_ALGEBROID,
  
  function( category )
    
    ##
    AddIsWellDefinedForObjects( category,
      function( o )
        
        o := UnderlyingVertex( o );
        
        return IsVertex( o ) and IsIdenticalObj( QuiverOfPath( o ), UnderlyingQuiver( category ) );
        
      end );
    
    ##
    AddIsWellDefinedForMorphisms( category,
      function( m )
        
        m := UnderlyingQuiverAlgebraElement( m );
        
        return IsPath( m ) and IsIdenticalObj( QuiverOfPath( m ), UnderlyingQuiver( category ) );
        
      end );
    
    ##
    AddIsEqualForObjects( category,
      function( object_1, object_2 )
        
        return UnderlyingVertex( object_1 ) = UnderlyingVertex( object_2 );
        
    end );
    
    ##
    AddIsEqualForMorphisms( category,
      function( morphism_1, morphism_2 )
        
        return UnderlyingQuiverAlgebraElement( morphism_1 ) = UnderlyingQuiverAlgebraElement( morphism_2 );
        
    end );
    
    ##
    AddIdentityMorphism( category,
      function( object )
        local A;
        
        A := UnderlyingQuiverAlgebra( CapCategory( object ) );
        
        return MorphismInAlgebroid(
                       object,
                       A.(String( UnderlyingVertex( object ) ) ),
                       object );
        
    end );
    
    ##
    AddPreCompose( category,
      function( morphism_1, morphism_2 )
        local B, quiver;
        
        B := CapCategory( morphism_1 );
        
        quiver := UnderlyingQuiver( B );
        
        if IsRightQuiver( quiver ) then
            return MorphismInAlgebroid(
                           Source( morphism_1 ),
                           UnderlyingQuiverAlgebraElement( morphism_1 ) * UnderlyingQuiverAlgebraElement( morphism_2 ),
                           Range( morphism_2 ) );
        else
            return MorphismInAlgebroid(
                           Source( morphism_1 ),
                           UnderlyingQuiverAlgebraElement( morphism_2 ) * UnderlyingQuiverAlgebraElement( morphism_1 ),
                           Range( morphism_2 ) );
        fi;
        
    end );
    
    ##
    AddAdditionForMorphisms( category,
      function( morphism_1, morphism_2 )
        
        return MorphismInAlgebroid(
                       Source( morphism_1 ),
                       UnderlyingQuiverAlgebraElement( morphism_1 ) + UnderlyingQuiverAlgebraElement( morphism_2 ),
                       Range( morphism_1 ) );
        
    end );
    
    ##
    AddAdditiveInverseForMorphisms( category,
      function( morphism )
        
        return MorphismInAlgebroid(
                       Source( morphism ),
                       -UnderlyingQuiverAlgebraElement( morphism ),
                       Range( morphism ) );
        
    end );
    
    ##
    AddMultiplyWithElementOfCommutativeRingForMorphisms( category,
      function( r, morphism )
        
        return MorphismInAlgebroid(
                       Source( morphism ),
                       r * UnderlyingQuiverAlgebraElement( morphism ),
                       Range( morphism ) );
        
    end );
    
    ##
    AddZeroMorphism( category,
      function( S, T )
        
        return MorphismInAlgebroid(
                       S,
                       Zero( UnderlyingQuiverAlgebra( CapCategory( S ) ) ),
                       T );
        
    end );
    
    Finalize( category );
    
    return category;
    
end );

##
InstallMethod( Algebroid,
        "for a QPA quiver algebra",
        [ IsQuiverAlgebra ],
        
  function( Rq )
    local parity, quiver, A;
    
    if IsRightQuiverAlgebra( Rq ) then
        parity := "right";
    else
        parity := "left";
    fi;
    
    quiver := QuiverOfAlgebra( Rq );
    
    if Length( Vertices( quiver ) ) > 1 then
        A := "Algebroid";
    else
        A := "Algebra";
    fi;
    
    A := Concatenation( A, " generated by the ", parity, " quiver ", String( quiver ) );
    
    A := CreateCapCategory( A );
    
    SetIsFinitelyPresentedCategory( A, true );
    SetUnderlyingQuiver( A, quiver );
    SetUnderlyingQuiverAlgebra( A, Rq );
    
    A!.Vertices := rec( );
    A!.Arrows := rec( );
    
    return ADD_FUNCTIONS_FOR_ALGEBROID( A );
    
end );

##
InstallMethod( Algebroid,
        "for a QPA path algebra and a list",
        [ IsPathAlgebra, IsList ],
        
  function( Rq, L )
    local path;
    
    for path in L do
        if not IsUniform( path ) then
            Error( "only uniform relations are admissible, while the path ", path, " is not uniform\n" );
        fi;
    od;
    
    L := Filtered( L, r -> not IsZero( r ) );
    
    return Algebroid( Rq / Ideal( Rq, L ) );
    
end );

##
InstallMethod( Algebroid,
        "for a homalg ring and a QPA quiver",
        [ IsHomalgRing, IsQuiver ],
        
  function( R, quiver )
    
    return Algebroid( PathAlgebra( R, quiver ) );
    
end );

##
InstallMethod( \.,
        "for an algebroid and a positive integer",
        [ IsCapCategory, IsPosInt ],
        
  function( B, string_as_int )
    local q, name, a, b;
    
    q := UnderlyingQuiver( B );
    
    name := NameRNam( string_as_int );
    
    a := q.(name);
    
    b := rec( );
    
    if IsVertex( a ) then
        if IsBound( B!.Vertices.(name) ) then
            return B!.Vertices.(name);
        fi;
        ObjectifyWithAttributes( b, TheTypeObjectInAlgebroid,
                UnderlyingVertex, a
                );
        B!.Vertices.(name) := b;
    elif IsArrow( a ) then
        if IsBound( B!.Arrows.(name) ) then
            return B!.Arrows.(name);
        fi;
        b := MorphismInAlgebroid(
                     B.(String( Source( a ) ) ),
                     PathAsAlgebraElement( UnderlyingQuiverAlgebra( B ), a ),
                     B.(String( Target( a ) ) ) );
        B!.Arrows.(name) := b;
    else
        Error( "the given component ", name, " is neither a vertex nor an arrow of the quiver q = ", q, "\n" );
    fi;
    
    Add( B, b );
    
    return b;
    
end );

##
InstallMethod( MorphismInAlgebroid,
        "for two objects in an algebroid and an element of the quiver algebra",
        [ IsCapCategoryObjectInAlgebroidRep, IsQuiverAlgebraElement, IsCapCategoryObjectInAlgebroidRep ],
        
  function( S, path, T )
    local l, mor, A;
    
    if not IsZero( path ) then
        
        if not IsUniform( path ) then
            Error( "the path ", path, " is neither zero nor uniform\n" );
        fi;
        
        ## TODO: we are avoiding for the moment the sanity test for
        ## elements of path algebras with relations, this should be
        ## reintroduced in the future
        if IsPathAlgebraElement( path ) then
            l := LeadingPath( path );
            
            if not ( Source( l ) = UnderlyingVertex( S ) and
                     Target( l ) = UnderlyingVertex( T ) ) then
                Error( "the path ", path, " is neither zero nor does it match the given source S or target T\n" );
            fi;
        fi;
        
    fi;
    
    mor := rec( );
    
    A := CapCategory( S );
    
    ObjectifyWithAttributes( mor, TheTypeMorphismInAlgebroid,
            Source, S,
            Range, T,
            UnderlyingQuiverAlgebraElement, path
            );
    
    Add( A, mor );
    
    return mor;
    
end );

##
InstallMethod( POW,
        "for a CAP category and an integer",
        [ IsCapCategory and HasUnderlyingQuiverAlgebra, IsInt ],
        
  function( A, n )
    local Rq, R, trivial_quiver, Rqq;
    
    if n < 0 or n > 2 then
        Error( "the only admissible values for n are 0,1,2\n" );
    elif n = 1 then
        return A;
    elif not IsBound( A!.powers ) then
        A!.powers := rec( );
    fi;
    
    Rq := UnderlyingQuiverAlgebra( A );
    
    R := LeftActingDomain( Rq );
    
    if n = 0 then
        
        if not IsBound( A!.powers.0 ) then
            
            if IsRightQuiverAlgebra( Rq ) then
                trivial_quiver := RightQuiver( "*(1)[]" );
            else
                trivial_quiver := LeftQuiver( "*(1)[]" );
            fi;
            
            A!.powers.0 := Algebroid( PathAlgebra( R, trivial_quiver ) );
            
        fi;
        
        return A!.powers.0;
        
    fi;
    
    # n = 2
    
    if not IsBound( A!.powers.2 ) then
        
        Rqq := TensorProductOfAlgebras( Rq, Rq );
        
        A!.powers.2 := Algebroid( Rqq );
        
    fi;
    
    return A!.powers.2;
    
end );

##
InstallMethod( CapFunctorFromFinitelyPresentedAlgebroid,
        "for a CAP category and a record",
        [ IsCapCategory, IsRecord ],
        
  function( A, F )
    local names, b, Rq, B, functor;
    
    names := NamesOfComponents( F );
    
    if names = [ ] then
        Error( "the record of images is empty\n" );
    fi;
    
    for b in names do
        if IsQuiverAlgebraElement( F.(b) ) then
            Rq := AlgebraOfElement( F.(b) );
            B := Algebroid( Rq );
            break;
        elif IsCapCategory( F.(b) ) then
            B := F.(b);
            break;
        elif IsCapCategoryCell( F.(b) ) then
            B := CapCategory( F.(b) );
            break;
        fi;
    od;
    
    if not IsBound( B ) then
        Error( "unable to extract target category from record of images\n" );
    fi;
    
    if IsBound( F.name ) then
        functor := F.name;
    else
        functor := Concatenation( "Functor from finitely presented ", Name( A ), " -> ", Name( B ) );
    fi;
    
    functor := CapFunctor( functor, A, B );
    
    functor!.defining_record := F;
    
    AddObjectFunction( functor,
            obj -> F.(String( UnderlyingVertex( obj ) )) );
    
    AddMorphismFunction( functor,
            function( new_source, mor, new_range )
              local coefs, paths;
              
              mor := UnderlyingQuiverAlgebraElement( mor );
              
              if IsQuotientOfPathAlgebraElement( mor ) then
                  mor := Representative( mor );
              fi;
              
              coefs := Coefficients( mor );
              
              paths := List( Paths( mor ), ArrowList );
              paths := List( paths, a -> PreCompose( List( a, b -> F.(String( b )) ) ) );
              
              return Sum( ListN( coefs, paths, function( r, p ) return r * p; end ) );
              
            end );
    
    return functor;
    
end );

##
InstallMethod( AddBialgebroidStructure,
        "for a CAP category and two records",
        [ IsCapCategory, IsRecord, IsRecord ],
        
  function( B, counit, comult )
    local vertices, B0, a, names, counit_functor, B2, o, comult_functor;
    
    B!.Name := Concatenation( "Bia", B!.Name{[ 2 .. Length( B!.Name ) ]} );
    
    vertices := List( Vertices( UnderlyingQuiver( B ) ), String );
    
    B0 := B^0;
    
    counit := ShallowCopy( counit );
    
    for a in NamesOfComponents( counit ) do
        if not IsCapCategoryMorphism( counit.(a) ) then
            counit.(a) := counit.(a) * IdentityMorphism( B0.1 );
        fi;
    od;
    
    ## we know how to map the objects
    for a in vertices do
        counit.(a) := B0.1;
    od;
    
    counit_functor := CapFunctorFromFinitelyPresentedAlgebroid( B, counit );
    
    if not IsIdenticalObj( B0, AsCapCategory( Range( counit_functor ) ) ) then
        Error( "counit_functor has a the wrong target category\n" );
    fi;
    
    SetCounit( B, counit_functor );
    
    B2 := B^2;
    
    comult := ShallowCopy( comult );
    
    ## we know how to map the objects
    for a in vertices do
        if IsInt( Int( a ) ) then
            o := Concatenation( a, "x", a );
        else
            o := Concatenation( a, a );
        fi;
        comult.(a) := B2.(o);
    od;
    
    comult_functor := CapFunctorFromFinitelyPresentedAlgebroid( B, comult );
    
    if not IsIdenticalObj( B2, AsCapCategory( Range( comult_functor ) ) ) then
        Error( "comult_functor has a the wrong target category\n" );
    fi;
    
    SetComultiplication( B, comult_functor );
    
    return B;
    
end );

####################################
#
# View, Print, and Display methods:
#
####################################

##
InstallMethod( ViewObj,
        "for an object in an algebroid",
        [ IsCapCategoryObjectInAlgebroidRep ],

  function( o )
    
    ViewObj( UnderlyingVertex( o ) );
    
end );

##
InstallMethod( ViewObj,
        "for a morphism in an algebroid",
        [ IsCapCategoryMorphismInAlgebroidRep ],

  function( o )
    
    if IsRightQuiverAlgebra( UnderlyingQuiverAlgebra( CapCategory( o ) ) ) then
        ViewObj( Source( o ) );
        Print( "-[" );
        ViewObj( UnderlyingQuiverAlgebraElement( o ) );
        Print( "]->" );
        ViewObj( Range( o ) );
    else
        ViewObj( Range( o ) );
        Print( "<-[" );
        ViewObj( UnderlyingQuiverAlgebraElement( o ) );
        Print( "]-" );
        ViewObj( Source( o ) );
    fi;
    
end );
