class CNNDamageTrigger extends DamageTrigger;

var() name destroyActorTag;

function Trigger(Actor Other, Pawn Instigator)
{
    MakeDamage();
    Super.Trigger(Other, Instigator);
}

function MakeDamage()
{
    local Actor actorToDamage;
    
    foreach AllActors(class 'Actor', actorToDamage, destroyActorTag)
    {
        actorToDamage.TakeDamage(damageAmount,
                                    none,
                                    Location,
                                    vect(0, 0, 0),
                                    damageType
        );
    }
}