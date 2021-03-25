const capitalize = (s) => {
    if (typeof s !== 'string') return ''
    return s.charAt(0).toUpperCase() + s.slice(1)
}

function useItem(item){
    $.post('http://malteInventory/use', JSON.stringify({
        item: item
    }));

    $.post('http://malteInventory/close', JSON.stringify({}));
    window.location.reload();
}

function dropItem(item, limit){
    let amount = Math.floor($("#dropamount").val())
    if(amount > 0 && amount <= limit){
        $.post('http://malteInventory/drop', JSON.stringify({
            item: item,
            amount: amount
        }));
    
        $.post('http://malteInventory/close', JSON.stringify({}));
        window.location.reload();
    }
}

var weight = 0

var menu = null
var mouseX = 0
var mouseY = 0
$(function(){
    menu = document.getElementById("contextmenu")
    $(document).mousemove(function(event) {
        mouseX = event.pageX;
        mouseY = event.pageY;
    });
})

document.addEventListener("click", function(e) {
	if(menu.style.display == "initial"){
  	menu.style.display = "none"
  }
}, false);

function dropItemsShower(amount,item){
    $('#dropOverlay').show()
    $('#dropWrapper').show()
    $("#dropamount").attr("placeholder", amount)
    $("#dropbutton").attr("onclick","dropItem('" + item + "', '" + amount + "')")
    $("#dropamount").select()
}

function canceldrop(){
    $('#dropOverlay').hide()
    $('#dropWrapper').hide()
}

function generation(items, stats){;
    let itemspot = document.getElementsByClassName("spot")
    for(let i = 0; i < items.length; i++){
        for(let j = 0; j < stats.length; j++){
            if(items[i]["item"] == stats[j]["name"]){
                weight += items[i]["amount"] * stats[j]["weight"]
            }
        }
        itemspot[i].style.backgroundColor = "rgb(17,17,17,0.6)"

        let itemimage = document.createElement("img")
        itemimage.setAttribute("src","./images/" + items[i]["item"] + ".png")
        itemimage.setAttribute("class","itemimage")
        $(itemimage).draggable()

        itemimage.addEventListener('contextmenu', function(e) {
            menu.style.display = "initial"
            menu.style.top = mouseY + "px"
            menu.style.left = mouseX + "px"
            //$("#drop").attr("onclick","dropItem('" + items[i]["item"] + "', '" + items[i]["amount"] + "')")
            $("#drop").attr("onclick","dropItemsShower('" + items[i]["amount"] + "', '" + items[i]["item"] + "')")
            $("#use").attr("onclick","useItem('" + items[i]["item"] + "')")
            e.preventDefault();
        }, false);

        itemspot[i].appendChild(itemimage)

        let itemname = document.createElement("span")
        itemname.innerHTML = capitalize(items[i]["item"])
        itemname.setAttribute("class","itemname")
        itemspot[i].appendChild(itemname)

        let itemamount = document.createElement("span")
        itemamount.innerHTML = items[i]["amount"]
        itemamount.setAttribute("class","itemamount")
        itemspot[i].appendChild(itemamount)
    }
    let weightelement = document.getElementById("weight")
    weightelement.style.width = weight + "%"
    let weightkg = document.getElementById("kg")
    weightkg.innerHTML = weight + "kg / 100kg" 
}

$(function() {
    bod = $("body")
    bod.hide()
    window.addEventListener("message", function(event) {
        var item = event.data;
        if(item.showhud){
            bod.show()
            window.addEventListener("keydown", function(event) {
                if(event.key == "F2" || event.key == "Escape" || event.key == "Backspace"){
                    $.post('http://malteInventory/close', JSON.stringify({}));
                    window.location.reload();
                }
            });
            generation(item.args, item.itemstats)
        }
        else if(!item.showhud) {
            bod.hide()
        }
    });
});
