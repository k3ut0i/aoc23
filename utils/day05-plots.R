plotmap <- function(filename){
    x <- read.table(filename, header=TRUE)
    sx <- x[[1]]; dx <- x[[3]]; sy <- x[[2]]; dy <- x[[4]]
    plot(c(sx, dx), c(sy, dy), xlab=names(x)[1], ylab=names(x)[2])
    segments(sx, sy, x1=dx, y1=dy)
    segments(dx[1:length(dx)-1], dy[1:length(dy)-1], x1=sx[2:length(sx)], y1=sy[2:length(sy)], lty=3, col='red')
}

plotall <- function(dirname, outputfile){
    png(file = outputfile, width = 1300, height = 1000)
    files <- list.files(dirname, pattern="*-*", full.name=TRUE)
    plot_cell_size <- ceiling(sqrt(length(files)))
    par(mfrow=c(plot_cell_size, plot_cell_size))
    lapply(files, plotmap)
    dev.off()
    return(outputfile);
}
