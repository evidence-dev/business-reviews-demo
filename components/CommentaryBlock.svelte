<script>
    import { onMount } from 'svelte'
    import Airtable from 'airtable'
    export let section = undefined;
    export let week_start = undefined;
    var base = new Airtable({apiKey: 'keyHqSGvALXEW5mvg'}).base('appF80Ib0QhiPrYxy');


    let commentary = [];

    let textAreaInput=''
  
  
    onMount(async () => {
        commentary = await getCommentary()
    })

    async function updateCommentary(){
        commentary = await getCommentary()
    }

async function getCommentary(){

    let results = await base('Commentary').select(
      {
        view: "Grid view"
      }
    ).all().then(function(records) {
      return records.map(function(record) {
        return record.fields
      })
    })
    console.log(results)
    return results
}


async function addCommentary(input){
    if (input === '') {
        return
    } else {
    base('Commentary').create([
        {
            "fields": {
                "Date": week_start,
                "Commentary": input,
                "Section": section
            }
        }
    ], 
    function(err, records) {
        if (err) {
            console.error(err);
            return;
        }
        updateCommentary()
    });
}
}

</script>



{#if commentary.filter(d => d.Section === section).filter(d => d.Date === week_start).length > 0}

{#each commentary.filter(d => d.Section === section).filter(d => d.Date === week_start) as comment}

<div class=commentary>{@html comment.Commentary}</div>

{/each}

{:else}

<div 
    class="editable commentary"
    contenteditable="true"
    bind:innerHTML={textAreaInput}
    placeholder="Add commentary here..."
>{textAreaInput}</div>

{#if textAreaInput !== '' && textAreaInput !== '<br>'}
<button on:click={addCommentary(textAreaInput)}>Submit</button>
{/if}

{/if}


<style>
    .commentary {
        display: block;
    }
    .editable:empty:before {
        content: attr(placeholder);
        color: #ccc;
    }
    .editable {
        padding: 5px;   
        width: 100%;
        resize: vertical;
    }

    .editable:focus {
        color: #000;
    }

    button{
            background-color: var(--blue-600);
            color: white;
            font-weight: bold;
            border-radius: 4px;
            border: 1px solid var(--blue-700);
            padding: 0.4em 1.10em;
            margin-top: 0.5em;
    }


</style>