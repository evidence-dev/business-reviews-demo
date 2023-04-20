<script>
    import { onMount } from 'svelte'
    import Airtable from 'airtable'
    export let section = undefined;
    export let week_start = undefined;

    import { key } from '$lib/stores.js'
    import { readOnly } from '$lib/stores.js'
    
    $: base = new Airtable({apiKey: $key}).base('appF80Ib0QhiPrYxy');

    let loaded_commentary = [];
    let loaded_comment = undefined;
    let submitted = false;

    let textAreaInput=''
  
  
    onMount(async () => {
        loaded_commentary = await getCommentary()
        loaded_comment = (loaded_commentary.filter(d => d.section === section).filter(d => d.date === week_start)[0] ?? 'unknown').commentary ?? undefined
    })

    async function updateDisplayedCommentary(){
        loaded_commentary = await getCommentary()
        loaded_comment = (loaded_commentary.filter(d => d.section === section).filter(d => d.date === week_start)[0] ?? 'unknown').commentary ?? undefined
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
                "date": week_start,
                "commentary": input,
                "section": section
            }
        }
    ], 
    function(err, records) {
        if (err) {
            console.error(err);
            return;
        }
        submit()
        updateDisplayedCommentary()
    });
}
}

async function editCommentary(input, section, week_start){
    base('Commentary').select({
        maxRecords: 5,
        view: "Grid view",
        filterByFormula: `AND(DATESTR(date) = "` + week_start +`", section = "` + section + `")`
    }).eachPage(function page(records, fetchNextPage) {
        // This function (`page`) will get called for each page of records.
    
        records.forEach(function(record) {
            console.log('Retrieved', record.getId());
            if (input === '' || input === '<br>') {
                base('Commentary').destroy(record.getId(), function(err, deletedRecord) {
                    if (err) {
                        console.error(err);
                        return;
                    }
                    console.log('Deleted record', deletedRecord.getId());
                    submit()
                    updateDisplayedCommentary()
                });
                return
            } else {
            base('Commentary').update([
                {
                    "id": record.getId(),
                    "fields": {
                        "commentary": input
                    }
                }
            ],
            function(err, records) {
                if (err) {
                    console.error(err);
                    return;
                }
                console.log("updated " + record.getId())
                submit()
                updateDisplayedCommentary()
            });
        }
            
        });
    
    }, function done(err) {
        if (err) { 
            console.error(err); 
            return; 
        }
    });
}    

function submit(){
    submitted = true
    setTimeout(() => {
        submitted = false
    }, 1000);
}

</script>



{#if loaded_commentary.filter(d => d.section === section).filter(d => d.date === week_start).length > 0}
    <!-- if there is existing commentary -->
    {#each loaded_commentary.filter(d => d.section === section).filter(d => d.date === week_start) as comment}
        <div 
            class="editable commentary" 
            contenteditable="true" 
            bind:innerHTML={comment.commentary}
        />
        {#if submitted}
        <button class=submitted>Saved</button>
        {:else}
            {#if comment.commentary !== loaded_comment}
            <button on:click={editCommentary(comment.commentary, section, week_start)}>Save</button>
                {#if $readOnly}<span class=error>Login to Save Edits</span>{/if}
            {/if}
        {/if}
    {/each}
{:else}
    <!-- if there is no existing commentary -->
    <div 
        class="editable commentary"
        contenteditable="true"
        bind:innerHTML={textAreaInput}
        placeholder="Add commentary here..."
    >
    {textAreaInput}
    </div>
    {#if submitted}
        <button class=submitted>Saved</button>
    {:else}
        {#if textAreaInput !== '' && textAreaInput !== '<br>'}
        <button on:click={addCommentary(textAreaInput)}>Save</button>
            {#if $readOnly}<span class=error>Login to Save Edits</span>{/if}
        {/if}
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
        border-left: 3px solid #ccc;
    }

    .editable:focus {
        color: #000;
    }

    button{
            background-color: var(--blue-500);
            color: white;
            font-weight: bold;
            border-radius: 4px;
            border: 1px solid var(--blue-600);
            padding: 0.4em 1.10em;
            margin-top: 1em;
            margin-bottom: 1em;
            cursor: pointer;
    }

    button.submitted {
        background-color: var(--green-600);
        border: 1px solid var(--green-700);
    }

    .error {
        color: var(--red-500);
        font-size: smaller;
        margin: 0.5em
    }

</style>