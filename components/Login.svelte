<script>
    
    let input = ''
    
    import { key } from '$lib/stores.js'
    import { mode } from '$lib/stores.js'
    import { readOnly } from '$lib/stores.js'

    import Airtable from 'airtable';

    let status = null
    let message = null

    function updateKey(value){
        $key = value 
        let result = testAPI()
        console.log(result)
        $readOnly = false
        input = ''
    }

    function testAPI(){
        let base = new Airtable({apiKey: $key}).base('appF80Ib0QhiPrYxy')
        base('Commentary').select({
        maxRecords: 1,
        view: "Grid view"
    }).eachPage(function page(records, fetchNextPage) {

        records.forEach(function(record) {
            console.log('Retrieved', record.get('date'));
        });
        fetchNextPage();

    }, function done(err) {
        if (err) { 
            console.error(err); 
            status = 'Error'
            message = 'This password is not valid.'
            return; }
    });
        }
</script>

<div class=card>
<small><b>Mode:</b> {#if $readOnly} Read Only {:else} Editable {/if}(<a href="/about">What's this?</a>)</small>
<br>
<input type="text" bind:value={input} placeholder="Password"/>

<button on:click={() => updateKey(input)}>Login to Edit</button>

{#if status === 'Error'}
<div class=error>{message}</div>
{/if}


</div>

<style>
    input {
        padding: 0.3em 0.5em;
        border-radius: 4px;
        border: 1px solid var(--grey-300);
    }
    
    button {
        background-color: var(--blue-500);
        color: white;
        font-weight: bold;
        border-radius: 4px;
        border: 1px solid var(--blue-600);
        padding: 0.3em 0.5em;
        margin: 0.5em;
        cursor: pointer;
    }

    small {
        font-family: var(--ui-font-family);
    }

    div.card {
        border: 1px solid var(--grey-300);
        padding: 1em;
        border-radius: 4px;
        background-color: var(--grey-100);
        margin: 1em 0em ;
    }

    div.error {
        color: var(--red-500);
        font-size: smaller;
    }
</style>