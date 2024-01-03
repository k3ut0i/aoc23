plotmap <- function(filename){
    x <- read.table(filename, header=TRUE)
    plot(x)
    lines(x)
}

plotall <- function(dirname, outputfile){
    png(file = outputfile, width = 1000, height = 700)
    files <- list.files(dirname, pattern="*-*", full.name=TRUE)
    plot_cell_size <- ceiling(sqrt(length(files)))
    par(mfrow=c(plot_cell_size, plot_cell_size))
    lapply(files, plotmap)
    dev.off()
    return(outputfile);
}
